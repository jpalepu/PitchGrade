import SwiftUI

struct AuthenticationView: View {
    enum Mode {
        case signIn, signUp
        
        var title: String {
            switch self {
            case .signIn: return "Welcome Back"
            case .signUp: return "Create Account"
            }
        }
        
        var subtitle: String {
            switch self {
            case .signIn: return "Sign in to continue"
            case .signUp: return "Choose how you want to register"
            }
        }
        
        var googleButtonText: String {
            switch self {
            case .signIn: return "Sign in with Google"
            case .signUp: return "Sign up with Google"
            }
        }
        
        var emailButtonText: String {
            switch self {
            case .signIn: return "Sign in with Email"
            case .signUp: return "Sign up with Email"
            }
        }
        
        var switchModeText: String {
            switch self {
            case .signIn: return "Don't have an account? Sign Up"
            case .signUp: return "Already have an account? Sign In"
            }
        }
    }
    
    let mode: Mode
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showEmailAuth = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text(mode.title)
                        .font(.title2.bold())
                    
                    Text(mode.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Auth Options
                VStack(spacing: 16) {
                    // Google Auth
                    Button {
                        Task {
                            await authViewModel.signInWithGoogle()
                        }
                    } label: {
                        HStack {
                            Image("google_logo") // Add this asset
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            
                            Text(mode.googleButtonText)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                    }
                    
                    // Email Auth
                    Button {
                        showEmailAuth = true
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.accentColor)
                            
                            Text(mode.emailButtonText)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Switch Mode Button
                Button {
                    dismiss()
                } label: {
                    Text(mode.switchModeText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showEmailAuth) {
                EmailAuthView(mode: mode)
                    .environmentObject(authViewModel)
            }
        }
    }
} 