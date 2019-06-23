import AppKit

final class Alert: NSWindow {
    private weak var back: NSView!
    
    init(_ title: String? = nil, message: String) {
        super.init(contentRect: NSRect(x: app.home.frame.midX - 200, y: app.home.frame.midY - 75, width: 400, height: 150),
                   styleMask: [.fullSizeContentView], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .clear
        isReleasedWhenClosed = false
        
        let back = NSView()
        back.translatesAutoresizingMaskIntoConstraints = false
        back.wantsLayer = true
        back.layer!.backgroundColor = NSColor.halo.withAlphaComponent(0.96).cgColor
        back.layer!.cornerRadius = 6
        back.layer!.borderWidth = 1
        back.layer!.borderColor = NSColor.black.cgColor
        back.alphaValue = 0
        contentView!.addSubview(back)
        self.back = back
        
        let label = Label()
        label.textColor = .black
        label.alignment = .center
        label.attributedStringValue = {
            if let title = title {
                $0.append(NSAttributedString(string: title + "\n", attributes: [.font: NSFont.systemFont(ofSize: 16, weight: .bold)]))
            }
            $0.append(NSAttributedString(string: message, attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .regular)]))
            return $0
        } (NSMutableAttributedString())
        back.addSubview(label)
        
        back.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        back.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        back.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        label.leftAnchor.constraint(equalTo: back.leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(equalTo: back.rightAnchor, constant: -20).isActive = true
        label.topAnchor.constraint(equalTo: back.topAnchor, constant: 20).isActive = true
        label.bottomAnchor.constraint(equalTo: back.bottomAnchor, constant: -20).isActive = true
        
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            back.alphaValue = 1
            app.home.contentView!.layoutSubtreeIfNeeded()
        }) { DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in self?.dismiss() } }
    }
    
    override func mouseDown(with: NSEvent) { dismiss() }
    
    private func dismiss() {
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            back.alphaValue = 0
        }) { [weak self] in self?.close() }
    }
}
