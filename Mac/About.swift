import AppKit

final class About: NSWindow {
    init() {
        super.init(contentRect: NSRect(
            x: (NSScreen.main!.frame.width - 200) / 2, y: (NSScreen.main!.frame.height - 250) / 2, width: 200, height: 200),
                   styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        isReleasedWhenClosed = false
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        image.image = NSImage(named: "logo")
        contentView!.addSubview(image)
        
        let label = Label(.local("About.label"))
        label.textColor = .halo
        label.font = .bold(20)
        contentView!.addSubview(label)
        
        let version = Label((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "")
        version.textColor = .halo
        version.font = .light(12)
        contentView!.addSubview(version)
        
        image.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor, constant: -25).isActive = true
        image.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: contentView!.centerYAnchor, constant: 20).isActive = true
        
        version.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        version.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 13:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                close()
            } else {
                super.keyDown(with: with)
            }
        case 53: close()
        default: super.keyDown(with: with)
        }
    }
}
