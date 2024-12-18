import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showEmailSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(.title2.bold())
                    
                    Text("Choose how you want to register")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Sign Up Options
                VStack(spacing: 16) {
                    // Google Sign Up
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
                            
                            Text("Sign up with Google")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                    }
                    
                    // Email Sign Up
                    Button {
                        showEmailSignUp = true
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.accentColor)
                            
                            Text("Sign up with Email")
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
                
                // Sign In Link
                Button {
                    dismiss()
                } label: {
                    Text("Already have an account? Sign In")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEmailSignUp) {
                EmailAuthView(mode: .signUp)
                    .environmentObject(authViewModel)
            }
        }
    }
} 