import Git
import UIKit

@UIApplicationMain class App: UIWindow, UIApplicationDelegate {
    static private(set) weak var shared: App!
    var margin = UIEdgeInsets.zero
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        App.shared = self
        makeKeyAndVisible()
        rootViewController = UIViewController()
        if #available(iOS 11.0, *) { margin = rootViewController!.view.safeAreaInsets }
        
        try! "hello world\n".write(to: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("file.txt"), atomically: true, encoding: .utf8)
        
        return true
    }
    
    override func safeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.safeAreaInsetsDidChange()
            margin = rootViewController!.view.safeAreaInsets
        }
    }
}
