import Pigit
import AppKit

@NSApplicationMain class App: NSWindow, NSApplicationDelegate {
    private weak var console: Console!
    private var repository: Repository?
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    override func cancelOperation(_: Any?) { makeFirstResponder(nil) }
    override func mouseDown(with: NSEvent) { makeFirstResponder(nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
        backgroundColor = .black
        NSApp.delegate = self
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.3).cgColor
        contentView!.addSubview(border)
        
        let console = Console()
        contentView!.addSubview(console)
        self.console = console
        
        var left = contentView!.leftAnchor
        [Button("Select", target: self, action: #selector(self.select)),
         Button("Select", target: self, action: #selector(self.select)),
         Button("Create", target: self, action: #selector(self.create)),
         Button("Delete", target: self, action: #selector(self.delete)),
         Button("Status", target: self, action: #selector(self.status))].forEach {
            contentView!.addSubview($0)
            $0.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -10).isActive = true
            $0.leftAnchor.constraint(equalTo: left, constant: 10).isActive = true
            left = $0.rightAnchor
        }
        
        border.topAnchor.constraint(equalTo: console.topAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 1).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -1).isActive = true
        
        console.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 80).isActive = true
        console.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        console.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        console.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        console.log("Start")
        
        DispatchQueue.global(qos: .background).async {
            guard
                let url = UserDefaults.standard.url(forKey: "url"),
                let access = UserDefaults.standard.data(forKey: "access") else { return }
            var stale = false
            _ = (try? URL(resolvingBookmarkData: access, options: .withSecurityScope, bookmarkDataIsStale:
                &stale))?.startAccessingSecurityScopedResource()
            self.validate(url)
        }
    }
    
    private func validate(_ url: URL) {
        console.log("Selecting: \(url.path)")
        Git.repository(url) {
            if $0 {
                self.console.log("This is a repository")
            } else {
                self.console.log("Not a repository")
            }
        }
    }
    
    @objc private func select() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.begin {
            if $0 == .OK {
                DispatchQueue.global(qos: .background).async {
                    UserDefaults.standard.set(panel.url, forKey: "url")
                    UserDefaults.standard.set((try! panel.url!.bookmarkData(options: .withSecurityScope)), forKey: "access")
                    self.validate(panel.url!)
                }
            }
        }
    }
    
    @objc private func open() {
        guard let url = UserDefaults.standard.url(forKey: "url") else { return }
        Git.open(url, error: {
            self.console.log($0.localizedDescription)
        }) {
            self.repository = $0
            self.console.log("Opened: \($0.url.path)")
        }
    }
    
    @objc private func create() {
        guard let url = UserDefaults.standard.url(forKey: "url") else { return }
        Git.create(url, error: {
            self.console.log($0.localizedDescription)
        }) {
            self.repository = $0
            self.console.log("Created: \($0.url.path)")
        }
    }
    
    @objc private func delete() {
        guard let repository = self.repository else { return }
        Git.delete(repository, error: {
            self.console.log($0.localizedDescription)
        }) {
            self.console.log("Deleted: \(repository.url.path)")
            self.repository = nil
        }
    }
    
    @objc private func status() {
        guard let repository = self.repository else { return }
    }
}
