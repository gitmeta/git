import Git
import AppKit

@NSApplicationMain class App: NSApplication, NSApplicationDelegate {
    private(set) static var menu: Menu!
    private(set) static var window: Window!
    private(set) static var repository: Repository? {
        didSet {
            if repository == nil {
                menu.project = false
                window.notRepository()
                window.list.update([])
            } else {
                menu.project = true
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
        
        Git.session.load { self.open() }
    }
    
    @objc func create() {
        Git.create(Git.session.url, error: {
            App.window.alert.error($0.localizedDescription)
        }) { App.repository = $0 }
    }
    
    @objc func panel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.begin {
            if $0 == .OK {
                Git.session.update(panel.url!, bookmark: (try! panel.url!.bookmarkData(options: .withSecurityScope))) {
                    self.open()
                }
            }
        }
    }
    
    @objc func preferences() { Credentials() }
    
    private func open() {
        guard !Git.session.bookmark.isEmpty
        else {
            App.window.showHelp(nil)
            return
        }
        var stale = false
        _ = (try? URL(resolvingBookmarkData: Git.session.bookmark, options: .withSecurityScope, bookmarkDataIsStale:
            &stale))?.startAccessingSecurityScopedResource()
        App.window.location.label.stringValue = Git.session.url.lastPathComponent
        App.window.branch.label.stringValue = ""
        Git.open(Git.session.url, error: {
            App.window.alert.error($0.localizedDescription)
            App.repository = nil
        }) { App.repository = $0 }
    }
}
