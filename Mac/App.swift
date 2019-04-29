import Git
import AppKit

@NSApplicationMain class App: NSApplication, NSApplicationDelegate {
    private(set) static var main: App!
    var session: Session!
    private(set) var window: Window!
    
    private(set) var repository: Repository? {
        didSet {
            if repository == nil {
                (mainMenu as! Menu).project.isEnabled = false
                window.notRepository()
                window.list.update([])
            } else {
                (mainMenu as! Menu).project.isEnabled = true
                repository!.updateStatus()
                repository!.status = { [weak self] in
                    if $0.isEmpty {
                        self?.window.upToDate()
                    } else {
                        self?.window.repository()
                    }
                    self?.window.list.update($0)
                }
            }
        }
    }
    
    override init() {
        super.init()
        delegate = self
        App.main = self
    }
    
    required init?(coder: NSCoder) { return nil }
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    
    func applicationDidFinishLaunching(_: Notification) {
        let window = Window()
        window.makeKeyAndOrderFront(nil)
        self.window = window
        
        mainMenu = Menu()
        
        Git.session { [weak self] in
            self?.session = $0
            guard !$0.bookmark.isEmpty else { return }
            var stale = false
            _ = (try? URL(resolvingBookmarkData: $0.bookmark, options: .withSecurityScope, bookmarkDataIsStale:
                &stale))?.startAccessingSecurityScopedResource()
            self?.open($0.url)
        }
    }
    
    @objc func create() {
        Git.create(session.url, error: { [weak self] in
            self?.window.alert.error($0.localizedDescription)
        }) { [weak self] in self?.repository = $0 }
    }
    
    @objc func panel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.begin { [weak self] in
            if $0 == .OK {
                self?.session.url = panel.url!
                self?.session.bookmark = (try! panel.url!.bookmarkData(options: .withSecurityScope))
                self?.open(panel.url!)
                if let session = self?.session {
                    Git.update(session)
                }
            }
        }
    }
    
    private func open(_ url: URL) {
        window.bar.label.stringValue = url.path
        Git.open(url, error: { [weak self] in
            self?.window.alert.error($0.localizedDescription)
            self?.repository = nil
        }) { [weak self] in
            self?.repository = $0
        }
    }
}
