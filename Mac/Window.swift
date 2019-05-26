import AppKit

class Window: NSWindow {
    init(_ rect: NSRect) {
        super.init(contentRect: rect,
                   styleMask: [.closable, .fullSizeContentView, .miniaturizable, .resizable, .titled, .unifiedTitleAndToolbar],
                   backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .window
        collectionBehavior = .fullScreenNone
        minSize = NSSize(width: 100, height: 100)
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
    }
}
