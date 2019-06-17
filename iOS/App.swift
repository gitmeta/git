import Git
import UIKit
import StoreKit
import UserNotifications

private(set) weak var app: App!

@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var update: ((State, [(URL, Status)]) -> Void)?
    private weak var tab: Tab!
    private(set) var repository: Repository? {
        didSet {
            if repository == nil {
                update?(.create, [])
            } else {
                repository!.status = { status in
                    self.repository?.packed {
                        if $0 {
                            self.update?(.packed, [])
                        } else {
                            self.update?(.ready, status)
                        }
                    }
                }
                update?(.loading, [])
                repository!.refresh()
            }
        }
    }
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        app = self
        let window = UIWindow()
        window.rootViewController = self
        window.makeKeyAndVisible()
        self.window = window
        
        Hub.session.load {
            if !Hub.session.bookmark.isEmpty {
                self.help()
                self.update?(.first, [])
            }
            Hub.session.update(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0], bookmark: Data()) {
                Hub.open(Hub.session.url, error: {
                    Alert($0.localizedDescription)
                    self.repository = nil
                }) {
                    self.repository = $0
                    Alert("hello world")
                }
            }
            self.rate()
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus != .authorized {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                }
            }
        }
        
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
    
    private func rate() {
        if let expected = UserDefaults.standard.value(forKey: "rating") as? Date {
            if Date() >= expected {
                var components = DateComponents()
                components.month = 4
                UserDefaults.standard.setValue(Calendar.current.date(byAdding: components, to: Date())!, forKey: "rating")
                if #available(iOS 10.3, *) { SKStoreReviewController.requestReview() }
            }
        } else {
            var components = DateComponents()
            components.day = 3
            UserDefaults.standard.setValue(Calendar.current.date(byAdding: components, to: Date())!, forKey: "rating")
        }
    }
    
    @objc private func help() { /*order(Help.self)*/ }
}
