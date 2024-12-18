import Foundation
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var error: String?
    @Published var user: FirebaseAuth.User?
    @Published var isLoading = false
    
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth: Auth, user: FirebaseAuth.User?) in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    func signInWithGoogle() async {
        isLoading = true
        do {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                throw AuthError.presentationError
            }
            
            // Get clientID from GoogleService-Info.plist
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                print("ERROR: No client ID found in Firebase configuration")
                throw AuthError.invalidCredential
            }
            
            // Configure and start Google Sign In
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            )
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.invalidCredential
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await auth.signIn(with: credential)
            self.user = authResult.user
            self.isAuthenticated = true
            print("DEBUG: Successfully signed in with Google")
            
        } catch {
            print("DEBUG: Google sign in error: \(error.localizedDescription)")
            handleError(error)
        }
        isLoading = false
    }
    
    func signInWithEmail(email: String, password: String) async {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            self.user = result.user
            self.isAuthenticated = true
        } catch {
            handleError(error)
        }
    }
    
    func signUpWithEmail(email: String, password: String, confirmPassword: String) async {
        isLoading = true
        print("DEBUG: Starting email sign up process")
        
        guard !email.isEmpty else {
            self.error = "Please enter an email"
            isLoading = false
            return
        }
        
        guard !password.isEmpty else {
            self.error = "Please enter a password"
            isLoading = false
            return
        }
        
        guard password == confirmPassword else {
            self.error = "Passwords don't match"
            isLoading = false
            return
        }
        
        do {
            print("DEBUG: Creating user with email: \(email)")
            let result = try await auth.createUser(withEmail: email, password: password)
            print("DEBUG: Successfully created user with ID: \(result.user.uid)")
            
            // Create user profile in Firestore
            let userData: [String: Any] = [
                "email": email,
                "createdAt": Timestamp(),
                "lastLogin": Timestamp()
            ]
            
            try await firestore
                .collection("users")
                .document(result.user.uid)
                .setData(userData)
            
            print("DEBUG: Created user profile in Firestore")
            
            await MainActor.run {
                self.user = result.user
                self.isAuthenticated = true
                print("DEBUG: User authenticated and state updated")
            }
        } catch {
            print("DEBUG: Sign up error: \(error.localizedDescription)")
            await MainActor.run {
                handleError(error)
            }
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        print("DEBUG: Handling error: \(error.localizedDescription)")
        if let authError = error as? AuthErrorCode {
            switch authError.code {
            case .invalidEmail:
                self.error = "Invalid email address"
            case .emailAlreadyInUse:
                self.error = "Email already in use"
            case .weakPassword:
                self.error = "Password must be at least 6 characters"
            case .wrongPassword:
                self.error = "Incorrect password"
            case .userNotFound:
                self.error = "Account not found"
            case .networkError:
                self.error = "Network error. Please check your connection"
            default:
                self.error = authError.localizedDescription
            }
        } else {
            self.error = error.localizedDescription
        }
        print("DEBUG: Error message set to: \(self.error ?? "nil")")
    }
}

enum AuthError: Error {
    case presentationError
    case invalidCredential
    case unknown
} 
