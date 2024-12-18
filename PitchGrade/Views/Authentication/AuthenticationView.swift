import SwiftUI

struct AuthenticationView: View {
    @State private var isSignIn = true
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isSignIn ? "Welcome Back" : "Create Account")
                .font(.title)
                .bold()
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(isSignIn ? .password : .newPassword)
            }
            .padding(.horizontal)
            
            Button(action: {
                if isSignIn {
                    authViewModel.signIn(email: email, password: password)
                } else {
                    authViewModel.signUp(email: email, password: password)
                }
            }) {
                Text(isSignIn ? "Sign In" : "Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: { isSignIn.toggle() }) {
                Text(isSignIn ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                    .foregroundColor(.accentColor)
            }
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
} 