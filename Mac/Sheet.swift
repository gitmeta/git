import AppKit

class Sheet: NSView {
    var ready: (() -> Void)?
    private(set) static weak var presented: Sheet?
    override var acceptsFirstResponder: Bool { return true }
    
    init() {
        App.window.makeFirstResponder(nil)
        super.init(frame: .zero)
        wantsLayer = true
        if Sheet.presented == nil {
            Sheet.presented = self
            App.menu.validate()
            translatesAutoresizingMaskIntoConstraints = false
            layer!.backgroundColor = NSColor.black.cgColor
            alphaValue = 0
            App.window.contentView!.addSubview(self)
            
            let blur = NSVisualEffectView(frame: .zero)
            blur.translatesAutoresizingMaskIntoConstraints = false
            blur.material = .ultraDark
            blur.blendingMode = .withinWindow
            blur.isHidden = true
            addSubview(blur)
            
            let terminate = NSButton()
            terminate.title = String()
            terminate.target = self
            terminate.action = #selector(close)
            terminate.isBordered = false
            terminate.keyEquivalent = "\u{1b}"
            addSubview(terminate)
            
            blur.topAnchor.constraint(equalTo: topAnchor).isActive = true
            blur.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            blur.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            blur.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            topAnchor.constraint(equalTo: App.window.contentView!.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: App.window.contentView!.bottomAnchor).isActive = true
            leftAnchor .constraint(equalTo: App.window.contentView!.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: App.window.contentView!.rightAnchor).isActive = true
            App.window.contentView!.layoutSubtreeIfNeeded()
            
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                context.allowsImplicitAnimation = true
                alphaValue = 1
            }) { [weak self, weak blur] in
                App.window.makeFirstResponder(self)
                blur?.isHidden = false
                self?.layer!.backgroundColor = NSColor.clear.cgColor
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
        App.window.makeFirstResponder(nil)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            context.allowsImplicitAnimation = true
            alphaValue = 0
        }) { [weak self] in self?.removeFromSuperview() }
    }
}
