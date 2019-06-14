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
        
        let borderTop = UIView()
        borderTop.isUserInteractionEnabled = true
        borderTop.translatesAutoresizingMaskIntoConstraints = false
        borderTop.backgroundColor = .shade
        view.addSubview(borderTop)
        
        let borderBottom = UIView()
        borderBottom.isUserInteractionEnabled = true
        borderBottom.translatesAutoresizingMaskIntoConstraints = false
        borderBottom.backgroundColor = .shade
        view.addSubview(borderBottom)
        
        [("add", #selector(add))].forEach {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage(named: $0.0), for: [])
            button.imageView!.clipsToBounds = true
            button.imageView!.contentMode = .center
            view.addSubview(button)
            
            
        }
        
        borderTop.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        borderTop.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        borderTop.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        borderBottom.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        borderBottom.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        borderBottom.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        if #available(iOS 11.0, *) {
            borderTop.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
            borderBottom.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true
        } else {
            borderTop.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
            borderBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive = true
        }
    }
    
    @objc private func add() { }
}
