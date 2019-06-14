import Git
import UIKit
import StoreKit
import UserNotifications

private(set) weak var app: App!

@UIApplicationMain class App: UIViewController, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        app = self
        let window = UIWindow()
        window.rootViewController = self
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tab = Tab()
        view.addSubview(tab)
        
        tab.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tab.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            tab.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            tab.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }
    
    @objc func add() { }
}
