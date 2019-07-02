import Git
import AppKit
import StoreKit
import UserNotifications

private(set) weak var app: App!

@NSApplicationMain final class App: NSApplication, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSTouchBarDelegate {
    private(set) weak var home: Home!
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
                refresh()
            }
        }
    }
    
    override init() {
        super.init()
        app = self
        delegate = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    required init?(coder: NSCoder) { return nil }
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    func browsed(_ url: URL) { Hub.session.update(url, bookmark: (try! url.bookmarkData(options: .withSecurityScope))) { self.load() } }
    
    @available(OSX 10.14, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent:
        UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 15) {
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
        button.target = self
        button.title = .key("Home.\(makeItemForIdentifier.rawValue)")
        switch makeItemForIdentifier.rawValue {
        case "directory":
            button.image = NSImage(named: "logotouch")
            button.imagePosition = .imageLeft
            button.imageScaling = .scaleNone
            button.bezelColor = .black
            button.action = #selector(browse)
        case "refresh": button.action = #selector(refresh)
        default: break
        }
        return item
    }
    
    func applicationDidFinishLaunching(_: Notification) {
        let home = Home()
        home.makeKeyAndOrderFront(nil)
        self.home = home
        
        let menu = NSMenu()
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.git"))
            $0.submenu!.items = [
                NSMenuItem(title: .key("Menu.about"), action: #selector(about), keyEquivalent: ""),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.preferences"), action: #selector(settings), keyEquivalent: ","),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.hide"), action: #selector(hide(_:)), keyEquivalent: "h"),
                { $0.keyEquivalentModifierMask = [.option, .command]
                    return $0
                } (NSMenuItem(title: .key("Menu.hideOthers"), action: #selector(hideOtherApplications(_:)), keyEquivalent: "h")),
                NSMenuItem(title: .key("Menu.showAll"), action: #selector(unhideAllApplications(_:)), keyEquivalent: ","),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.quit"), action: #selector(terminate(_:)), keyEquivalent: "q")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.project"))
            $0.submenu!.items = [
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.directory"), action: #selector(browse), keyEquivalent: "o")),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.cloud"), action: #selector(cloud), keyEquivalent: ""),
                NSMenuItem.separator(),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.refresh"), action: #selector(refresh), keyEquivalent: "r")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.log"), action: #selector(history), keyEquivalent: "y")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.commit"), action: #selector(add), keyEquivalent: "\r")),
                { $0.keyEquivalentModifierMask = [.command, .control, .shift]
                    return $0
                } (NSMenuItem(title: .key("Menu.reset"), action: #selector(reset), keyEquivalent: "r"))]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.edit"))
            $0.submenu!.items = [
                { $0.keyEquivalentModifierMask = [.option, .command]
                    $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.undo"), action: Selector(("undo:")), keyEquivalent: "z")),
                { $0.keyEquivalentModifierMask = [.command, .shift]
                    return $0
                } (NSMenuItem(title: .key("Menu.redo"), action: Selector(("redo:")), keyEquivalent: "z")),
                NSMenuItem.separator(),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.cut"), action: #selector(NSText.cut(_:)), keyEquivalent: "x")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.copy"), action: #selector(NSText.copy(_:)), keyEquivalent: "c")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.paste"), action: #selector(NSText.paste(_:)), keyEquivalent: "v")),
                NSMenuItem(title: .key("Menu.delete"), action: #selector(NSText.delete(_:)), keyEquivalent: ""),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.selectAll"), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.window"))
            $0.submenu!.items = [
                NSMenuItem(title: .key("Menu.minimize"), action: #selector(Home.performMiniaturize(_:)), keyEquivalent: "m"),
                NSMenuItem(title: .key("Menu.zoom"), action: #selector(Home.performZoom(_:)), keyEquivalent: "p"),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.bringAllToFront"), action: #selector(arrangeInFront(_:)), keyEquivalent: "")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        menu.addItem({
            $0.submenu = NSMenu(title: .key("Menu.help"))
            $0.submenu!.items = [NSMenuItem(title: .key("Menu.showHelp"), action: #selector(help), keyEquivalent: "/")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        mainMenu = menu
        
        Hub.session.load {
            self.load()
            self.rate()
        }
        
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus != .authorized {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 15) {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                    }
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
                    DispatchQueue.main.async { Alert(title, message: message).makeKeyAndOrderFront(nil) }
                }
            }
        } else {
            DispatchQueue.main.async { Alert(title, message: message).makeKeyAndOrderFront(nil) }
        }
    }
    
    @objc func create() {
        home.update(.loading)
        restore()
        Hub.create(Hub.session.url, error: {
            self.alert(.key("Alert.error"), message: $0.localizedDescription)
            self.repository = nil
        }) {
            self.repository = $0
            self.alert(.key("Alert.success"), message: .key("Home.created"))
        }
    }
    
    @objc func unpack() {
        home.update(.loading)
        restore()
        repository?.unpack({
            self.alert(.key("Alert.error"), message: $0.localizedDescription)
            self.repository = nil
        }) {
            self.alert(.key("Alert.success"), message: .key("App.unpacked"))
        }
    }
    
    @objc func browse() {
        restore()
        let browse = NSOpenPanel()
        browse.canChooseFiles = false
        browse.canChooseDirectories = true
        browse.begin { [weak browse] in
            guard $0 == .OK, let url = browse?.url else { return }
            self.browsed(url)
        }
    }
    
    @objc func refresh() {
        guard let repository = repository else { return }
        home.update(.loading)
        repository.refresh()
    }
    
    @objc func cloud() {
        if Hub.session.bookmark.isEmpty {
            browse()
        } else {
            if Hub.session.purchase.contains(.cloud) {
                order(Cloud.self)
            } else {
                app.alert(.key("Alert.purchase"), message: .key("Cloud.purchase"))
            }
        }
    }
    
    @objc func market() { order(Market.self) }
    @objc func settings() { order(Settings.self) }
    @objc func add() { orderIfReady(Add.self) }
    @objc func history() { orderIfReady(History.self) }
    @objc func reset() { orderIfReady(Reset.self) }
    
    private func load() {
        guard !Hub.session.bookmark.isEmpty
        else {
            help()
            home.update(.first)
            return
        }
        var stale = false
        _ = (try? URL(resolvingBookmarkData: Hub.session.bookmark, options: .withSecurityScope, bookmarkDataIsStale:
            &stale))?.startAccessingSecurityScopedResource()
        home.directory.label.stringValue = Hub.session.url.lastPathComponent
        Hub.open(Hub.session.url, error: {
            Alert(message: $0.localizedDescription).makeKeyAndOrderFront(nil)
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
    
    @discardableResult private func orderIfReady<W: NSWindow>(_ type: W.Type) -> W? {
        if repository == nil {
            if Hub.session.bookmark.isEmpty {
                browse()
            } else {
                Alert(message: .key("App.noRepository")).makeKeyAndOrderFront(nil)
            }
            return nil
        }
        return order(type)
    }
    
    @discardableResult private func order<W: NSWindow>(_ type: W.Type) -> W {
        if let window = windows.compactMap({ $0 as? W }).first {
            window.orderFront(nil)
            return window
        }
        let w = W()
        w.makeKeyAndOrderFront(nil)
        return w
    }
    
    private func restore() { windows.filter({ !($0 is Home) }).forEach({ $0.close() }) }
    @objc private func help() { order(Help.self) }
    @objc private func about() { order(About.self) }
}
