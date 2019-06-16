import Git
import UIKit
import StoreKit
import UserNotifications

private(set) weak var app: App!

@UIApplicationMain final class App: UIViewController, UIApplicationDelegate {
    var window: UIWindow?
    private weak var tab: Tab!
    
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
        self.tab = tab

        tab.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tab.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            tab.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            tab.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        show(Home())
    }
    
    func show(_ content: UIView) {
        view.subviews.forEach({ if $0 != tab { $0.removeFromSuperview() } })
        view.addSubview(content)
        
        content.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: tab.topAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            content.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
    }
}
