import Git
import AppKit

@NSApplicationMain class App: NSWindow, NSApplicationDelegate {
    private(set) static var shared: App!
    private(set) var url: URL?
    private(set) var repository: Repository?
    private weak var bar: Bar!
    private weak var directory: Button!
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    override func cancelOperation(_: Any?) { makeFirstResponder(nil) }
    override func mouseDown(with: NSEvent) { makeFirstResponder(nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        App.shared = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
        backgroundColor = .black
        NSApp.delegate = self
        
        let bar = Bar()
        contentView!.addSubview(bar)
        self.bar = bar
        
        let directory = Button(.local("App.directory"), target: self, action: #selector(self.prompt))
        directory.isHidden = true
        directory.layer!.backgroundColor = NSColor.warning.cgColor
        directory.width.constant = 140
        contentView!.addSubview(directory)
        self.directory = directory
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 7).isActive = true
        bar.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 75).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -7).isActive = true
        
        directory.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        directory.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        
        DispatchQueue.global(qos: .background).async {
            guard
                let url = UserDefaults.standard.url(forKey: "url"),
                let access = UserDefaults.standard.data(forKey: "access")
            else {
                DispatchQueue.main.async {
                    directory.isHidden = false
                    bar.isHidden = true
                }
                return
            }
            var stale = false
            _ = (try? URL(resolvingBookmarkData: access, options: .withSecurityScope, bookmarkDataIsStale:
                &stale))?.startAccessingSecurityScopedResource()
            self.select(url)
        }
    }
    
    private func select(_ url: URL) {
        self.url = url
        Git.repository(url) {
            if $0 {
                
            } else {
                
            }
        }
    }
    
    @objc private func prompt() {
        
    }
}
