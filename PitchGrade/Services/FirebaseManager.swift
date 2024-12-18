import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseAppCheck
import GoogleSignIn
import GoogleSignInSwift
import DeviceCheck

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {}
    
    func configure() {
        // Configure Firebase
        FirebaseApp.configure()
        
        #if DEBUG
        // Use debug provider for simulator
        if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
            let debugProvider = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(debugProvider)
            print("DEBUG: Using App Check debug provider for simulator")
        }
        #endif
        
        print("DEBUG: Firebase configured")
    }
    
    func configureGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("ERROR: Failed to get clientID from Firebase options")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        print("DEBUG: Google Sign In configured with clientID: \(clientID)")
    }
} 