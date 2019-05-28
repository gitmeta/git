import AppKit

class About: NSWindow {
    init() {
        super.init(contentRect: NSRect(
            x: (NSScreen.main!.frame.width - 350) / 2, y: (NSScreen.main!.frame.height - 350) / 2, width: 350, height: 350),
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
        label.font = .bold(16)
        contentView!.addSubview(label)
        
        let version = Label((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "")
        version.textColor = .halo
        version.font = .light(16)
        contentView!.addSubview(version)
        
        image.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: contentView!.centerYAnchor, constant: 80).isActive = true
        
        version.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        version.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
    }
}
