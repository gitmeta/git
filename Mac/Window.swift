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
        minSize = NSSize(width: 50, height: 50)
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
        tools.isHidden = true
        contentView!.addSubview(tools)
        self.tools = tools
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 5).isActive = true
        bar.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 72).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -5).isActive = true
        
        list.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 10).isActive = true
        list.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: tools.topAnchor, constant: -10).isActive = true
        
        display.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        display.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        display.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        display.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        
        tools.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        tools.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        tools.heightAnchor.constraint(equalToConstant: 200).isActive = true
        tools.bottom = tools.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: 200)
        
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
        tools.isHidden = false
        tools.bottom.constant = 0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = 1
            display.repository()
        }) { }
    }
    
    func notRepository() {
        tools.bottom.constant = tools.frame.height
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
        tools.bottom.constant = tools.frame.height
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.6
            context.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            list.alphaValue = 1
            display.upToDate()
        }) { [weak self] in
            self?.tools.isHidden = true
        }
    }
    
    @objc func showHelp(_: Any?) { Onboard() }
}
