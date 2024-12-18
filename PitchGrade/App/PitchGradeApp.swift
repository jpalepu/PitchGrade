import SwiftUI
import Firebase
import FirebaseCore
import GoogleSignIn

@main
struct PitchGradeApp: App {
    @StateObject private var viewModel = PitchViewModel()
    
    init() {
        FirebaseApp.configure()
        
        // Configure Google Sign In
        if let clientID = FirebaseApp.app()?.options.clientID {
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
} 
