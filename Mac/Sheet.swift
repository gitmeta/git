import AppKit

class Sheet: NSView {
    private static weak var presented: Sheet?
    override var acceptsFirstResponder: Bool { return true }
    
    init() {
        App.shared.makeFirstResponder(nil)
        super.init(frame: .zero)
        if Sheet.presented == nil {
            Sheet.presented = self
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
            layer!.backgroundColor = NSColor.shade.cgColor
            alphaValue = 0
            App.shared.contentView!.addSubview(self)
            
            let terminate = NSButton()
            terminate.title = String()
            terminate.target = self
            terminate.action = #selector(close)
            terminate.isBordered = false
            terminate.keyEquivalent = "\u{1b}"
            addSubview(terminate)
            
            topAnchor.constraint(equalTo: App.shared.contentView!.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: App.shared.contentView!.bottomAnchor).isActive = true
            leftAnchor .constraint(equalTo: App.shared.contentView!.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: App.shared.contentView!.rightAnchor).isActive = true
            
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.4
                context.allowsImplicitAnimation = true
                alphaValue = 1
            }) { App.shared.makeFirstResponder(self) }
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    override func mouseDown(with: NSEvent) { }
    override func mouseDragged(with: NSEvent) { }
    override func mouseUp(with: NSEvent) { }
    
    override func keyDown(with: NSEvent) {
        if with.keyCode == 53 {
            close()
        } else {
            super.keyDown(with: with)
        }
    }
    
    @objc func close() {
        App.shared.makeFirstResponder(nil)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            alphaValue = 0
        }) { [weak self] in self?.removeFromSuperview() }
    }
}
