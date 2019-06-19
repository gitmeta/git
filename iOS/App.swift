import Git
import UIKit
import StoreKit
import UserNotifications

private(set) weak var app: App!

@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, UNUserNotificationCenterDelegate, UIDocumentBrowserViewControllerDelegate {
    var window: UIWindow?
    private(set) weak var home: Home!
    private(set) weak var add: Add!
    private weak var tab: Tab!
    private(set) var repository: Repository? {
        didSet {
            if repository == nil {
                home.update(.create)
            } else {
                repository!.status = { status in
                    self.repository?.packed {
                        if $0 {
                            self.home.update(.packed)
                        } else {
                            self.home.update(.ready, items: status)
                        }
                    }
                }
                home.update(.loading)
                repository!.refresh()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let home = Home()
        self.home = home
        
        let add = Add()
        self.add = add
        
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
        
        [home, add].forEach {
            $0.isHidden = true
            view.addSubview($0)
            
            $0.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            $0.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: tab.topAnchor).isActive = true
            
            if #available(iOS 11.0, *) {
                $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            } else {
                $0.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            }
        }
        
        show(home)
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
                self.home.update(.first)
            }
            Hub.session.update(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0], bookmark: Data()) {
                Hub.open(Hub.session.url, error: {
                    Alert($0.localizedDescription)
                    self.repository = nil
                }) {
                    self.repository = $0
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
    
    @available(iOS 10.0, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent: UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 15) {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [willPresent.request.identifier])
        }
    }
    
    @available(iOS 11.0, *) func documentBrowser(_: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let create = Create { didRequestDocumentCreationWithHandler($0, $0 == nil ? .none : .move) }
        presentedViewController!.view.addSubview(create)
        
        create.topAnchor.constraint(equalTo: presentedViewController!.view.topAnchor).isActive = true
        create.bottomAnchor.constraint(equalTo: presentedViewController!.view.bottomAnchor).isActive = true
        create.leftAnchor.constraint(equalTo: presentedViewController!.view.leftAnchor).isActive = true
        create.rightAnchor.constraint(equalTo: presentedViewController!.view.rightAnchor).isActive = true
    }
    
    @available(iOS 11.0, *) func documentBrowser(_: UIDocumentBrowserViewController, didPickDocumentsAt: [URL]) {
        let share = UIActivityViewController(activityItems: didPickDocumentsAt, applicationActivities: nil)
        share.popoverPresentationController?.sourceView = presentedViewController!.view
        share.popoverPresentationController?.sourceRect = .zero
        share.popoverPresentationController?.permittedArrowDirections = .any
        presentedViewController!.present(share, animated: true)
    }
    
    func alert(_ title: String, message: String) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus == .authorized {
                    UNUserNotificationCenter.current().add({
                        $0.title = title
                        $0.body = message
                        return UNNotificationRequest(identifier: UUID().uuidString, content: $0, trigger: nil)
                    } (UNMutableNotificationContent()))
                } else {
                    Alert(title + " " + message)
                }
            }
        } else {
            Alert(title + " " + message)
        }
    }
    
    func show(_ view: UIView) { [home, add].forEach { $0?.isHidden = $0 !== view } }
    
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
    
    @objc func browse() {
        if #available(iOS 11.0, *) {
            let browse = UIDocumentBrowserViewController()
            browse.browserUserInterfaceStyle = .dark
            browse.delegate = self
            browse.additionalLeadingNavigationBarButtonItems = [.init(barButtonSystemItem: .stop, target: self, action: #selector(back))]
            present(browse, animated: true)
        }
    }
    
    @objc func create() {
        home.update(.loading)
        Hub.create(Hub.session.url, error: {
            self.alert(.local("Alert.error"), message: $0.localizedDescription)
            self.repository = nil
        }) {
            self.repository = $0
            self.alert(.local("Alert.success"), message: .local("Home.created"))
        }
    }
    
    @objc func unpack() {
        home.update(.loading)
        repository?.unpack({
            self.alert(.local("Alert.error"), message: $0.localizedDescription)
            self.repository = nil
        }) {
            self.alert(.local("Alert.success"), message: .local("App.unpacked"))
        }
    }
    
    @objc private func help() { /*order(Help.self)*/ }
    @objc private func back() { dismiss(animated: true) }
}
