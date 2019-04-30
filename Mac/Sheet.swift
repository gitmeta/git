import AppKit

class Sheet: NSView {
    private static weak var presented: Sheet?
    override var acceptsFirstResponder: Bool { return true }
    
    init() {
        App.window.makeFirstResponder(nil)
        super.init(frame: .zero)
        wantsLayer = true
        if Sheet.presented == nil {
            Sheet.presented = self
            translatesAutoresizingMaskIntoConstraints = false
            alphaValue = 0
            NSApp.mainWindow!.contentView!.addSubview(self)
            
            let terminate = NSButton()
            terminate.title = String()
            terminate.target = self
            terminate.action = #selector(close)
            terminate.isBordered = false
            terminate.keyEquivalent = "\u{1b}"
            addSubview(terminate)
            
            topAnchor.constraint(equalTo: NSApp.mainWindow!.contentView!.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: NSApp.mainWindow!.contentView!.bottomAnchor).isActive = true
            leftAnchor .constraint(equalTo: NSApp.mainWindow!.contentView!.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: NSApp.mainWindow!.contentView!.rightAnchor).isActive = true
            NSApp.mainWindow!.contentView!.layoutSubtreeIfNeeded()
            
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                context.allowsImplicitAnimation = true
                alphaValue = 1
            }) { App.window.makeFirstResponder(self) }
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
        App.window.makeFirstResponder(nil)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            context.allowsImplicitAnimation = true
            alphaValue = 0
        }) { [weak self] in self?.removeFromSuperview() }
    }
}
