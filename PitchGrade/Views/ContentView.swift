import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if !authViewModel.isAuthenticated {
                if !viewModel.hasSeenOnboarding {
                    LandingPagesView()
                        .environmentObject(authViewModel)
                } else {
                    AuthenticationView(mode: .signIn)
                        .environmentObject(authViewModel)
                }
            } else {
                MainTabView()
                    .environmentObject(authViewModel)
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                print("DEBUG: User authenticated, showing MainTabView")
            }
        }
    }
} 