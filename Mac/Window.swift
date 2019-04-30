import AppKit
import UserNotifications

class Window: NSWindow, UNUserNotificationCenterDelegate, NSUserNotificationCenterDelegate {
    let alert = Alert()
    private(set) weak var list: List!
    private(set) weak var tools: Tools!
    private(set) weak var bar: Bar!
    private weak var display: Display!
    
    init() {
        super.init(contentRect: NSRect(x: (NSScreen.main!.frame.width - 600) / 2, y: (NSScreen.main!.frame.height - 600) / 2,
                   width: 600, height: 600), styleMask: [.closable, .fullSizeContentView, .miniaturizable, .resizable,
                                                         .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .shade
        collectionBehavior = .fullScreenNone
        minSize = NSSize(width: 250, height: 250)
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
        
        let display = Display()
        contentView!.addSubview(display)
        self.display = display
        
        let bar = Bar()
        contentView!.addSubview(bar)
        self.bar = bar
        
        let list = List()
        contentView!.addSubview(list)
        self.list = list
        
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
        
        display.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        display.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        display.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        display.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        
        tools.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        tools.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        tools.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        
        NSUserNotificationCenter.default.delegate = self
        
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
        }
    }
    
    func userNotificationCenter(_: NSUserNotificationCenter, shouldPresent: NSUserNotification) -> Bool { return true }
    @available(OSX 10.14, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent:
        UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
    }
    
    func repository() {
        tools.height.constant = 180
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = 1
            display.repository()
        }) { }
    }
    
    func notRepository() {
        tools.height.constant = 0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = 0
            display.notRepository()
        }) { }
    }
    
    func upToDate() {
        tools.height.constant = 0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = 1
            display.upToDate()
        }) { }
    }
    
    @objc private func showHelp(_ : Any?) { Onboard() }
}
