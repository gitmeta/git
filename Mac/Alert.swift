import AppKit

final class Alert: NSWindow {
    init(_ message: String) {
        super.init(contentRect: NSRect(
            x: (NSScreen.main!.frame.width - 400) / 2, y: (NSScreen.main!.frame.height - 90) / 2, width: 400, height: 90),
                   styleMask: [.fullSizeContentView], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .clear
        isReleasedWhenClosed = false
        
        let back = NSView()
        back.translatesAutoresizingMaskIntoConstraints = false
        back.wantsLayer = true
        back.layer!.backgroundColor = NSColor(white: 0, alpha: 0.7).cgColor
        back.layer!.cornerRadius = 8
        back.layer!.borderWidth = 1
        back.layer!.borderColor = NSColor.shade.cgColor
        back.alphaValue = 0
        contentView!.addSubview(back)
        
        let label = Label(message)
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.alignment = .center
        back.addSubview(label)
        
        back.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        back.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        back.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        back.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        label.centerYAnchor.constraint(equalTo: back.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: back.centerXAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 350).isActive = true
        
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            back.alphaValue = 1
            app.home.contentView!.layoutSubtreeIfNeeded()
        }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                NSAnimationContext.runAnimationGroup({
                    $0.duration = 0.5
                    $0.allowsImplicitAnimation = true
                    back.alphaValue = 0
                }) { [weak self] in
                    self?.close()
                }
            }
        }
    }
}
