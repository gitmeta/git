import AppKit

class Warning: NSWindow {
    init() {
        super.init(contentRect: NSRect(
            x: (NSScreen.main!.frame.width - 300) / 2, y: (NSScreen.main!.frame.height - 190) / 2, width: 300, height: 140),
                   styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .docModalWindow], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .shade
        isReleasedWhenClosed = false
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        image.image = NSImage(named: "error")
        contentView!.addSubview(image)
        
        let label = Label(.local("Warning.label"))
        label.textColor = .halo
        label.font = .bold(14)
        contentView!.addSubview(label)
        
        image.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 140).isActive = true
        
        label.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: image.rightAnchor).isActive = true
    }
}
