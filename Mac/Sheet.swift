import AppKit

class Sheet: NSView {
    var ready: (() -> Void)?
    private(set) static weak var presented: Sheet?
    override var acceptsFirstResponder: Bool { return true }
    
    init() {
        App.home.makeFirstResponder(nil)
        super.init(frame: .zero)
        wantsLayer = true
        if Sheet.presented == nil {
            Sheet.presented = self
            App.menu.validate()
            translatesAutoresizingMaskIntoConstraints = false
            layer!.backgroundColor = NSColor.shade.cgColor
            alphaValue = 0
            App.home.contentView!.addSubview(self)
            
            let terminate = NSButton()
            terminate.title = String()
            terminate.target = self
            terminate.action = #selector(close)
            terminate.isBordered = false
            terminate.keyEquivalent = "\u{1b}"
            addSubview(terminate)
            
            topAnchor.constraint(equalTo: App.home.contentView!.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: App.home.contentView!.bottomAnchor).isActive = true
            leftAnchor .constraint(equalTo: App.home.contentView!.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: App.home.contentView!.rightAnchor).isActive = true
            App.home.contentView!.layoutSubtreeIfNeeded()
            
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                context.allowsImplicitAnimation = true
                alphaValue = 1
            }) { [weak self] in
                App.home.makeFirstResponder(self)
                self?.ready?()
            }
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    deinit { App.menu.validate() }
    
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
        App.home.makeFirstResponder(nil)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            context.allowsImplicitAnimation = true
            alphaValue = 0
        }) { [weak self] in
            self?.removeFromSuperview()
        }
    }
}
