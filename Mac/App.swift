import Git
import AppKit
import UserNotifications

@NSApplicationMain class App: NSWindow, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSUserNotificationCenterDelegate {
    let alert = Alert()
    private(set) static var shared: App!
    private(set) var url: URL?
    private(set) var repository: Repository?
    private(set) weak var list: List!
    private weak var bar: Bar!
    private weak var directory: Button!
    private weak var tools: Tools!
    private weak var none: None!
    private let timer = DispatchSource.makeTimerSource(queue: .global(qos: .background))
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    override func cancelOperation(_: Any?) { makeFirstResponder(nil) }
    override func mouseDown(with: NSEvent) { makeFirstResponder(nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        App.shared = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
        backgroundColor = .black
        NSApp.delegate = self
        
        let none = None()
        contentView!.addSubview(none)
        self.none = none
        
        let bar = Bar()
        bar.isHidden = true
        contentView!.addSubview(bar)
        self.bar = bar
        
        let list = List()
        contentView!.addSubview(list)
        self.list = list
        
        let directory = Button(.local("App.directory"), target: self, action: #selector(self.prompt))
        directory.isHidden = true
        directory.layer!.backgroundColor = NSColor.warning.cgColor
        directory.width.constant = 120
        contentView!.addSubview(directory)
        self.directory = directory
        
        let tools = Tools()
        contentView!.addSubview(tools)
        self.tools = tools
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        list.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 1).isActive = true
        list.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: tools.topAnchor, constant: -1).isActive = true
        
        none.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        none.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        none.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        none.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        
        directory.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        directory.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        
        tools.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        tools.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        tools.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        
        timer.resume()
//        timer.setEventHandler { self.repository?.status { s in self.list.items.forEach { $0.status = s[$0.url] ?? .current } } }
        timer.schedule(deadline: .now(), repeating: 2)
        
        NSUserNotificationCenter.default.delegate = self
        
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
        }
        
        DispatchQueue.global(qos: .background).async {
            guard
                let url = UserDefaults.standard.url(forKey: "url"),
                let access = UserDefaults.standard.data(forKey: "access")
            else {
                DispatchQueue.main.async { directory.isHidden = false }
                return
            }
            var stale = false
            _ = (try? URL(resolvingBookmarkData: access, options: .withSecurityScope, bookmarkDataIsStale:
                &stale))?.startAccessingSecurityScopedResource()
            self.select(url)
        }
    }
    
    func userNotificationCenter(_: NSUserNotificationCenter, shouldPresent: NSUserNotification) -> Bool { return true }
    @available(OSX 10.14, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent:
        UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
    }
    
    @objc func prompt() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.begin {
            if $0 == .OK {
                DispatchQueue.global(qos: .background).async {
                    UserDefaults.standard.set(panel.url, forKey: "url")
                    UserDefaults.standard.set((try! panel.url!.bookmarkData(options: .withSecurityScope)), forKey: "access")
                    self.select(panel.url!)
                }
            }
        }
    }
    
    @objc func start() {
        Git.create(url!, error: { self.alert.show($0.localizedDescription) }) {
            self.repository = $0
            self.show()
        }
    }
    
    private func select(_ url: URL) {
        self.url = url
        Git.open(url, error: {
            self.alert.show($0.localizedDescription)
            self.repository = nil
            self.hide()
        }) {
            self.repository = $0
            self.show()
        }
        DispatchQueue.main.async {
            self.bar.isHidden = false
            self.directory.isHidden = true
            self.bar.label.stringValue = url.path
        }
    }
    
    private func show() {
        list.show()
        tools.height.constant = 120
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = 1
            none.alphaValue = 0
        }) { }
    }
    
    private func hide() {
        tools.height.constant = 0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = 0
            none.alphaValue = 1
        }) {
            self.list.items.forEach { $0.removeFromSuperview() }
        }
    }
}
