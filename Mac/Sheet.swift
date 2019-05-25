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
            App.window.list.documentView!.subviews.forEach({ $0.removeFromSuperview() })
            
            Sheet.presented = self
            App.menu.validate()
            translatesAutoresizingMaskIntoConstraints = false
            layer!.backgroundColor = NSColor.shade.cgColor
            alphaValue = 0
            App.window.contentView!.addSubview(self)
            
            let terminate = NSButton()
            terminate.title = String()
            terminate.target = self
            terminate.action = #selector(close)
            terminate.isBordered = false
            terminate.keyEquivalent = "\u{1b}"
            addSubview(terminate)
            
            topAnchor.constraint(equalTo: App.window.contentView!.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: App.window.contentView!.bottomAnchor).isActive = true
            leftAnchor .constraint(equalTo: App.window.contentView!.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: App.window.contentView!.rightAnchor).isActive = true
            App.window.contentView!.layoutSubtreeIfNeeded()
            
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                context.allowsImplicitAnimation = true
                alphaValue = 1
            }) { [weak self] in
                App.window.makeFirstResponder(self)
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
        App.window.refresh()
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            context.allowsImplicitAnimation = true
            alphaValue = 0
        }) { [weak self] in
            self?.removeFromSuperview()
        }
    }
}
