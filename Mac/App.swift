import Git
import AppKit
import StoreKit
import UserNotifications

private(set) weak var app: App!

@NSApplicationMain final class App: NSApplication, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSTouchBarDelegate {
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
                self.refresh()
            }
        }
    }
    
    private(set) weak var home: Home!
    
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
            button.title = .local("Home.refresh")
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
        
        let menu = Menu()
        mainMenu = menu
        
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
    
    func alert(_ title: String, message: String) {
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus == .authorized {
                    UNUserNotificationCenter.current().add({
                        $0.title = title
                        $0.body = message
                        return UNNotificationRequest(identifier: UUID().uuidString, content: $0, trigger: nil)
                    } (UNMutableNotificationContent()))
                } else {
                    Alert(title + " " + message).makeKeyAndOrderFront(nil)
                }
            }
        } else {
            Alert(title + " " + message).makeKeyAndOrderFront(nil)
        }
    }
    
    @objc func browse() {
        windows.filter({ !($0 is Home) && !($0 is NSOpenPanel) }).forEach({ $0.close() })
        if let browse = windows.first(where: { $0 is NSOpenPanel }) {
            browse.orderFront(nil)
        } else {
            let browse = NSOpenPanel()
            browse.canChooseFiles = false
            browse.canChooseDirectories = true
            browse.begin { [weak browse] in
                guard let url = browse?.url, $0 == .OK else { return }
                Hub.session.update(url, bookmark: (try! url.bookmarkData(options: .withSecurityScope))) {
                    self.load()
                }
            }
        }
    }
    
    @objc func refresh() {
        guard let repository = repository else { return }
        home.update(.loading)
        repository.refresh()
    }
    
    @objc func settings() { order(Settings.self) }
    @objc func help() { order(Help.self) }
    @objc func about() { order(About.self) }
    
    @objc func add() {
        if repository == nil {
            Alert(.local("App.noRepository")).makeKeyAndOrderFront(nil)
        } else {
            order(Add.self)
        }
    }
    
    @objc func history() {
        if repository == nil {
            Alert(.local("App.noRepository")).makeKeyAndOrderFront(nil)
        } else {
            order(History.self)
        }
    }
    
    @objc func reset() {
        if repository == nil {
            Alert(.local("App.noRepository")).makeKeyAndOrderFront(nil)
        } else {
            order(Reset.self)
        }
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
            Alert($0.localizedDescription).makeKeyAndOrderFront(nil)
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
    
    private func order<W: NSWindow>(_ type: W.Type) {
        if let window = windows.first(where: { $0 is W }) {
            window.orderFront(nil)
        } else {
            W().makeKeyAndOrderFront(nil)
        }
    }
}
