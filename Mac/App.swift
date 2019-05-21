import Git
import AppKit
import StoreKit

@NSApplicationMain class App: NSApplication, NSApplicationDelegate {
    static var repository: Repository? {
        didSet {
            repository?.branch { window.branch.label.stringValue = $0 }
            menu.validate()
            if repository == nil {
                window.notRepository()
                window.list.update([])
            } else {
                repository!.status = { [weak repository] status in
                    repository?.packed {
                        if $0 {
                            window.packed()
                        } else {
                            if status.isEmpty {
                                window.upToDate()
                            } else {
                                window.repository()
                            }
                            window.list.update(status)
                        }
                    }
                }
                window.refresh()
            }
        }
    }
    
    private(set) static var menu: Menu!
    private(set) static var window: Window!
    
    override init() {
        super.init()
        delegate = self
    }
    
    required init?(coder: NSCoder) { return nil }
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    
    func applicationDidFinishLaunching(_: Notification) {
        let window = Window()
        App.window = window
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
    
    private func open() {
        guard !Hub.session.bookmark.isEmpty
        else {
            App.window.showHelp(nil)
            return
        }
        var stale = false
        _ = (try? URL(resolvingBookmarkData: Hub.session.bookmark, options: .withSecurityScope, bookmarkDataIsStale:
            &stale))?.startAccessingSecurityScopedResource()
        App.window.location.label.stringValue = Hub.session.url.lastPathComponent
        App.window.branch.label.stringValue = ""
        Hub.open(Hub.session.url, error: {
            App.window.alert.error($0.localizedDescription)
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
