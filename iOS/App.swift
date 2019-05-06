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
        let display = Display()
        rootViewController!.view.addSubview(display)
        
        display.topAnchor.constraint(equalTo: rootViewController!.view.topAnchor).isActive = true
        display.bottomAnchor.constraint(equalTo: rootViewController!.view.bottomAnchor).isActive = true
        display.leftAnchor.constraint(equalTo: rootViewController!.view.leftAnchor).isActive = true
        display.rightAnchor.constraint(equalTo: rootViewController!.view.rightAnchor).isActive = true
        
        Hub.session.load {
            if Hub.session.bookmark.isEmpty {
                Onboard()
            } else {
                
            }
        }
        
        return true
    }
    
    override func safeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.safeAreaInsetsDidChange()
            margin = rootViewController!.view.safeAreaInsets
        }
    }
}
