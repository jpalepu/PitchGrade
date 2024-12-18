import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    
    var body: some View {
        if !viewModel.hasSeenOnboarding {
            LandingPagesView()
        } else {
            MainTabView()
        }
    }
} 