import AppKit

class About: NSWindow {
    init() {
        super.init(contentRect: NSRect(
            x: (NSScreen.main!.frame.width - 300) / 2, y: (NSScreen.main!.frame.height - 300) / 2, width: 300, height: 300),
                   styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
    }
}
