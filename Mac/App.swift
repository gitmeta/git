import Git
import AppKit
import StoreKit
import UserNotifications

private(set) weak var app: App!

@NSApplicationMain class App: NSApplication, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSTouchBarDelegate {
    private(set) var repository: Repository? {
        didSet {
            options.validate()
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
                self.refresh()
            }
        }
    }
    
    private(set) weak var options: Menu!
    private(set) weak var home: Home!
    private(set) weak var open: NSOpenPanel?
    let alert = Alert()
    
    override init() {
        super.init()
        app = self
        delegate = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    required init?(coder: NSCoder) { return nil }
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    
    @available(OSX 10.14, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent:
        UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 10) {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [willPresent.request.identifier])
        }
    }
    
    @available(OSX 10.12.2, *) override func makeTouchBar() -> NSTouchBar? {
        let bar = NSTouchBar()
        bar.delegate = self
        bar.defaultItemIdentifiers = [.init("directory"), .init("refresh")]
        return bar
    }
    
    @available(OSX 10.12.2, *) func touchBar(_: NSTouchBar, makeItemForIdentifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let item = NSCustomTouchBarItem(identifier: makeItemForIdentifier)
        let button = NSButton(title: "", target: nil, action: nil)
        item.view = button
        switch makeItemForIdentifier.rawValue {
        case "directory":
            button.title = .local("Home.directory")
            button.image = NSImage(named: "logotouch")
            button.imagePosition = .imageLeft
            button.imageScaling = .scaleNone
            button.bezelColor = .black
            button.target = self
            button.action = #selector(browse)
        case "refresh":
            button.title = .local("Menu.refresh")
            button.target = self
            button.action = #selector(refresh)
        default: break
        }
        return item
    }
    
    func applicationDidFinishLaunching(_: Notification) {
        let home = Home()
        home.makeKeyAndOrderFront(nil)
        self.home = home
        
        let options = Menu()
        mainMenu = options
        self.options = options
        
        Hub.session.load {
            self.load()
            self.rate()
        }
        
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus != .authorized {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                }
            }
        }
    }
    
    @objc func browse() {
        if let open = self.open {
            open.orderFront(nil)
        } else {
            let open = NSOpenPanel()
            open.canChooseFiles = false
            open.canChooseDirectories = true
            open.begin { [weak open] in
                guard let open = open, $0 == .OK else { return }
                Hub.session.update(open.url!, bookmark: (try! open.url!.bookmarkData(options: .withSecurityScope))) {
                    self.load()
                }
            }
            self.open = open
        }
    }
    
    @objc func settings() { Credentials() }
    
    @objc func refresh() {
        guard repository != nil else { return }
        home.update(.loading)
        repository?.refresh()
    }
    
    @objc func help() {
        Onboard()
    }
    
    private func load() {
        guard !Hub.session.bookmark.isEmpty
        else {
            help()
            return
        }
        var stale = false
        _ = (try? URL(resolvingBookmarkData: Hub.session.bookmark, options: .withSecurityScope, bookmarkDataIsStale:
            &stale))?.startAccessingSecurityScopedResource()
        home.directory.label.stringValue = Hub.session.url.lastPathComponent
        Hub.open(Hub.session.url, error: {
            self.alert.error($0.localizedDescription)
            self.repository = nil
        }) { self.repository = $0 }
    }
    
    private func rate() {
        if let expected = UserDefaults.standard.value(forKey: "rating") as? Date {
            if Date() >= expected {
                var components = DateComponents()
                components.month = 4
                UserDefaults.standard.setValue(Calendar.current.date(byAdding: components, to: Date())!, forKey: "rating")
                if #available(OSX 10.14, *) { SKStoreReviewController.requestReview() }
            }
        } else {
            var components = DateComponents()
            components.day = 3
            UserDefaults.standard.setValue(Calendar.current.date(byAdding: components, to: Date())!, forKey: "rating")
        }
    }
}
