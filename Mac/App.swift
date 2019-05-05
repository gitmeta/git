import Git
import AppKit

@NSApplicationMain class App: NSApplication, NSApplicationDelegate {
    private(set) static var menu: Menu!
    private(set) static var window: Window!
    private(set) static var repository: Repository? {
        didSet {
            window.branch.label.stringValue = App.repository?.branch ?? ""
            menu.validate()
            if repository == nil {
                window.notRepository()
                window.list.update([])
            } else {
                window.refresh()
                repository!.status = {
                    if $0.isEmpty {
                        window.upToDate()
                    } else {
                        window.repository()
                    }
                    window.list.update($0)
                }
            }
        }
    }
    
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
        
        Hub.session.load { self.open() }
    }
    
    @objc func create() {
        Hub.create(Hub.session.url, error: {
            App.window.alert.error($0.localizedDescription)
        }) { App.repository = $0 }
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
}
