import Git
import AppKit

@NSApplicationMain class App: NSApplication, NSApplicationDelegate {
    static var session: Session!
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
        
        Git.session {
            App.session = $0
            self.open()
        }
    }
    
    @objc func create() {
        Git.create(App.session.url, error: {
            App.window.alert.error($0.localizedDescription)
        }) { App.repository = $0 }
    }
    
    @objc func panel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.begin {
            if $0 == .OK {
                App.session.url = panel.url!
                App.session.bookmark = (try! panel.url!.bookmarkData(options: .withSecurityScope))
                Git.update(App.session)
                self.open()
            }
        }
    }
    
    @objc func preferences() { Credentials() }
    
    private func open() {
        guard !App.session.bookmark.isEmpty
        else {
            App.window.showHelp(nil)
            return
        }
        var stale = false
        _ = (try? URL(resolvingBookmarkData: App.session.bookmark, options: .withSecurityScope, bookmarkDataIsStale:
            &stale))?.startAccessingSecurityScopedResource()
        App.window.bar.label.stringValue = App.session.url.lastPathComponent
        Git.open(App.session.url, error: {
            App.window.alert.error($0.localizedDescription)
            App.repository = nil
        }) { App.repository = $0 }
    }
}
