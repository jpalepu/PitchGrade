import SwiftUI

@main
struct PitchGradeApp: App {
    @StateObject private var viewModel = PitchViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
} 