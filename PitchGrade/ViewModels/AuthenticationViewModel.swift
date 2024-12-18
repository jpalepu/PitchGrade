import Foundation

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var hasSeenOnboarding = false {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
        }
    }
    
    init() {
        hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
    
    func signIn(email: String, password: String) {
        // Simple validation
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        // For now, just authenticate
        isAuthenticated = true
    }
    
    func signUp(email: String, password: String) {
        // Simple validation
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        // For now, just authenticate
        isAuthenticated = true
    }
    
    func signOut() {
        isAuthenticated = false
    }
} 