import Git
import UIKit
import StoreKit
import UserNotifications

private(set) weak var app: App!

@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, UNUserNotificationCenterDelegate, UIDocumentBrowserViewControllerDelegate {
    var window: UIWindow?
    private(set) weak var tab: Tab!
    private(set) weak var _home: Home!
    private(set) weak var _history: History!
    private(set) weak var _settings: Settings!
    private weak var _market: Market!
    private weak var _add: Add!
    var repository: Repository? {
        didSet {
            if repository == nil {
                _home.update(.create)
            } else {
                repository!.status = { status in
                    self.repository?.packed {
                        if $0 {
                            self._home.update(.packed)
                        } else {
                            self._home.update(.ready, items: status)
                        }
                    }
                }
                _home.update(.loading)
                repository!.refresh()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _settings = Settings()
        self._settings = _settings
        
        let _market = Market()
        self._market = _market
        
        let _home = Home()
        self._home = _home
        
        let _add = Add()
        self._add = _add
        
        let _history = History()
        self._history = _history
        
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
        
        [_settings, _market, _home, _add, _history].forEach {
            $0.isHidden = true
            $0.clipsToBounds = true
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
        
        show(_home)
    }
    
    func application(_: UIApplication, open: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        _ = open.startAccessingSecurityScopedResource()
        try? Data(contentsOf: open).write(to: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(open.lastPathComponent), options: .atomic)
        open.stopAccessingSecurityScopedResource()
        return true
    }
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        app = self
        let window = UIWindow()
        window.rootViewController = self
        window.makeKeyAndVisible()
        self.window = window
        
        Hub.session.load {
            self.load()
            self.rate()
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus != .authorized {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 15) {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                    }
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
                    DispatchQueue.main.async { Alert(title, message: message) }
                }
            }
        } else {
            DispatchQueue.main.async { Alert(title, message: message) }
        }
    }
    
    func market() {
        show(_market)
        _market.start()
    }
    
    func add() {
        if repository == nil {
            Alert(message: .key("App.noRepository"))
            tab.home.choose()
        } else {
            show(_add)
            _add.text.becomeFirstResponder()
        }
    }
    
    func history() {
        if repository == nil {
            Alert(message: .key("App.noRepository"))
            tab.home.choose()
        } else {
            show(_history)
            _history.load(false)
        }
    }
    
    func load() {
        if Hub.session.bookmark.isEmpty {
            help()
            _home.update(.first)
        }
        Hub.session.update(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0], bookmark: Data(" ".utf8)) {
            Hub.open(Hub.session.url, error: {
                Alert(message: $0.localizedDescription)
                self.repository = nil
            }) {
                self.repository = $0
            }
        }
    }
    
    func settings() { show(_settings) }
    func home() { show(_home) }
    func help() { Help() }
    
    @objc func browse() {
        if #available(iOS 11.0, *) {
            let browse = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: ["public.content", "public.data"])
            browse.popoverPresentationController?.sourceView = view
            browse.browserUserInterfaceStyle = .dark
            browse.delegate = self
            browse.additionalLeadingNavigationBarButtonItems = [.init(barButtonSystemItem: .stop, target: self, action: #selector(back))]
            present(browse, animated: true)
        } else {
            alert(.key("Alert.error"), message: .key("App.ios.version"))
        }
    }
    
    @objc func refresh() {
        guard let repository = repository else { return }
        _home.update(.loading)
        repository.refresh()
    }
    
    @objc func create() {
        _home.update(.loading)
        Hub.create(Hub.session.url, error: {
            self.alert(.key("Alert.error"), message: $0.localizedDescription)
            self.repository = nil
        }) {
            self.repository = $0
            self.alert(.key("Alert.success"), message: .key("Home.created"))
        }
    }
    
    @objc func unpack() {
        _home.update(.loading)
        repository?.unpack({
            self.alert(.key("Alert.error"), message: $0.localizedDescription)
            self.repository = nil
        }) {
            self.alert(.key("Alert.success"), message: .key("App.unpacked"))
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
    
    private func show(_ view: UIView) { [_settings, _market, _home, _add, _history].forEach { $0?.isHidden = $0 !== view } }
    @objc private func back() { dismiss(animated: true) }
}
