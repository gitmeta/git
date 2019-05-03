import AppKit
import UserNotifications

class Window: NSWindow, UNUserNotificationCenterDelegate {
    let alert = Alert()
    private(set) weak var list: List!
    private(set) weak var tools: Tools!
    private(set) weak var location: Bar!
    private(set) weak var branch: Bar!
    private weak var display: Display!
    
    init() {
        super.init(contentRect: NSRect(x: (NSScreen.main!.frame.width - 600) / 2, y: (NSScreen.main!.frame.height - 600) / 2,
                   width: 600, height: 600), styleMask: [.closable, .fullSizeContentView, .miniaturizable, .resizable,
                                                         .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .shade
        collectionBehavior = .fullScreenNone
        minSize = NSSize(width: 400, height: 400)
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false

        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
        
        let display = Display()
        contentView!.addSubview(display)
        self.display = display
        
        let location = Bar.Location()
        contentView!.addSubview(location)
        self.location = location
        
        let branch = Bar.Branch()
        contentView!.addSubview(branch)
        self.branch = branch
        
        let list = List()
        contentView!.addSubview(list)
        self.list = list
        
        let tools = Tools()
        contentView!.addSubview(tools)
        self.tools = tools
        
        location.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 6).isActive = true
        location.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 74).isActive = true
        
        branch.topAnchor.constraint(equalTo: location.topAnchor).isActive = true
        branch.leftAnchor.constraint(equalTo: location.rightAnchor, constant: -16).isActive = true
        branch.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -7).isActive = true
        
        list.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        list.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: tools.topAnchor, constant: -1).isActive = true
        
        display.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        display.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        display.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        display.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        
        tools.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        tools.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        tools.top = tools.topAnchor.constraint(equalTo: contentView!.bottomAnchor)
        
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
        }
    }
    
    @available(OSX 10.14, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent:
        UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
    }
    
    func repository() {
        tools.isHidden = false
        tools.top.constant = -tools.frame.height
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = 1
            display.repository()
        }) { }
    }
    
    func notRepository() {
        tools.top.constant = 0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = 0
            display.notRepository()
        }) { [weak self] in
            self?.tools.isHidden = true
        }
    }
    
    func upToDate() {
        tools.isHidden = false
        tools.top.constant = -tools.frame.height
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = 0
            display.upToDate()
        }) { }
    }
    
    @objc func refresh() {
        App.repository?.refresh()
        tools.top.constant = 0
        list.documentView!.subviews.forEach { $0.removeFromSuperview() }
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = 0
            display.logo()
        }) { [weak self] in
            self?.tools.isHidden = true
        }
    }
    
    @objc func showHelp(_: Any?) { Onboard() }
}
