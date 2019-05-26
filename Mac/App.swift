import Git
import AppKit
import StoreKit

@NSApplicationMain class App: NSApplication, NSApplicationDelegate {
    static var repository: Repository? {
        didSet {
            repository?.branch { home.branch.label.stringValue = $0 }
            menu.validate()
            if repository == nil {
                home.notRepository()
                home.list.update([])
            } else {
                repository!.status = { [weak repository] status in
                    repository?.packed {
                        if $0 {
                            home.packed()
                        } else {
                            if status.isEmpty {
                                home.upToDate()
                            } else {
                                home.repository()
                            }
                            home.list.update(status)
                        }
                    }
                }
                App.global.refresh()
            }
        }
    }
    
    private(set) static weak var global: App!
    private(set) static weak var menu: Menu!
    private(set) static weak var home: Home!
    
    override init() {
        super.init()
        App.global = self
        delegate = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    required init?(coder: NSCoder) { return nil }
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    
    func applicationDidFinishLaunching(_: Notification) {
        let window = Home()
        App.home = window
        window.makeKeyAndOrderFront(nil)
        
        let menu = Menu()
        App.menu = menu
        mainMenu = menu
        
        Hub.session.load {
            self.open()
            self.rate()
        }
    }
    
    @objc func panel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.begin {
            if $0 == .OK {
                Hub.session.update(panel.url!, bookmark: (try! panel.url!.bookmarkData(options: .withSecurityScope))) {
                    self.open()
                }
            }
        }
    }
    
    @objc func preferences() { Credentials() }
    
    @objc func refresh() {
        App.repository?.refresh()
        App.home.showRefresh()
    }
    
    private func open() {
        guard !Hub.session.bookmark.isEmpty
        else {
            App.home.showHelp(nil)
            return
        }
        var stale = false
        _ = (try? URL(resolvingBookmarkData: Hub.session.bookmark, options: .withSecurityScope, bookmarkDataIsStale:
            &stale))?.startAccessingSecurityScopedResource()
        App.home.location.label.stringValue = Hub.session.url.lastPathComponent
        App.home.branch.label.stringValue = ""
        Hub.open(Hub.session.url, error: {
            App.home.alert.error($0.localizedDescription)
            App.repository = nil
        }) { App.repository = $0 }
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
