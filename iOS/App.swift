import Git
import UIKit
import StoreKit
import UserNotifications

private(set) weak var app: App!

@UIApplicationMain final class App: UIViewController, UIApplicationDelegate {
    var window: UIWindow?
    private weak var bar: Bar!
    
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
        
        let bar = Bar()
        self.bar = bar
        
        tab.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tab.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        bar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            tab.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            tab.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            bar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
    }
    
    @objc func add() { }
}
