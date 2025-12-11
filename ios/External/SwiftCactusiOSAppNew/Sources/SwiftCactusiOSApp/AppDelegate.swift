import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var launchScreenWindow: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create a simple launch screen
        showLaunchScreen()
        
        // Dismiss launch screen after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismissLaunchScreen()
        }
        
        return true
    }
    
    private func showLaunchScreen() {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
        
        if let windowScene = windowScene {
            launchScreenWindow = UIWindow(windowScene: windowScene)
            
            // Create a simple view for the launch screen
            let launchView = UIView()
            launchView.backgroundColor = .systemBackground
            
            // Add a label
            let label = UILabel()
            label.text = "Cactus AI"
            label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            launchView.addSubview(label)
            
            // Center the label
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: launchView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: launchView.centerYAnchor)
            ])
            
            launchScreenWindow?.rootViewController = UIViewController()
            launchScreenWindow?.rootViewController?.view = launchView
            launchScreenWindow?.makeKeyAndVisible()
        }
    }
    
    private func dismissLaunchScreen() {
        UIView.animate(withDuration: 0.3) {
            self.launchScreenWindow?.alpha = 0
        } completion: { _ in
            self.launchScreenWindow = nil
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
