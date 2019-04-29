import AppKit
import UserNotifications

class Window: NSWindow, UNUserNotificationCenterDelegate {
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
    }
}
