import Git
import AppKit

final class Cloud: NSWindow, NSTextFieldDelegate {
    private final class Field: NSView {
        private(set) weak var field: NSTextField!
        
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let label = Label(.local("Cloud.field"))
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.textColor = NSColor(white: 1, alpha: 0.4)
            addSubview(label)
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
            addSubview(border)
            
            let field = NSTextField()
            field.translatesAutoresizingMaskIntoConstraints = false
            field.isBezeled = false
            field.font = .systemFont(ofSize: 15, weight: .regular)
            field.focusRingType = .none
            field.drawsBackground = false
            field.textColor = .white
            field.maximumNumberOfLines = 1
            field.lineBreakMode = .byTruncatingHead
            if #available(OSX 10.12.2, *) {
                field.isAutomaticTextCompletionEnabled = false
            }
            addSubview(field)
            self.field = field
            
            widthAnchor.constraint(equalToConstant: 460).isActive = true
            heightAnchor.constraint(equalToConstant: 45).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            field.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 6).isActive = true
            field.heightAnchor.constraint(equalToConstant: 30).isActive = true
            field.leftAnchor.constraint(equalTo: leftAnchor, constant: 60).isActive = true
            field.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private weak var segment: NSSegmentedControl!
    private weak var left: NSLayoutConstraint!
    private weak var cloneField: Field!
    private weak var loading: NSImageView!
    private weak var buttonClone: Button!
    
    init() {
        super.init(contentRect: NSRect(
            x: app.home.frame.minX + 50, y: app.home.frame.maxY - 220, width: 500, height: 170),
                   styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .shade
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        contentView!.addSubview(border)
        
        let segment = NSSegmentedControl()
        segment.target = self
        segment.action = #selector(choose)
        segment.segmentCount = 3
        segment.setLabel(.local("Cloud.clone.title"), forSegment: 0)
        segment.setLabel(.local("Cloud.pull.title"), forSegment: 1)
        segment.setLabel(.local("Cloud.push.title"), forSegment: 2)
        segment.translatesAutoresizingMaskIntoConstraints = false
        contentView!.addSubview(segment)
        self.segment = segment
        
        let clone = NSView()
        clone.translatesAutoresizingMaskIntoConstraints = false
        contentView!.addSubview(clone)
        
        let pull = NSView()
        pull.translatesAutoresizingMaskIntoConstraints = false
        contentView!.addSubview(pull)
        
        let push = NSView()
        push.translatesAutoresizingMaskIntoConstraints = false
        contentView!.addSubview(push)
        
        let loading = NSImageView()
        loading.image = NSImage(named: "loading")
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.imageScaling = .scaleNone
        loading.isHidden = true
        contentView!.addSubview(loading)
        self.loading = loading
        
        if app.repository == nil {
            let cloneField = Field()
            cloneField.field.delegate = self
            clone.addSubview(cloneField)
            self.cloneField = cloneField
            
            let buttonClone = Button.Text(self, action: #selector(makeClone))
            buttonClone.label.stringValue = .local("Cloud.clone.button")
            buttonClone.label.font = .systemFont(ofSize: 11, weight: .medium)
            buttonClone.label.textColor = .black
            buttonClone.wantsLayer = true
            buttonClone.layer!.cornerRadius = 4
            buttonClone.layer!.backgroundColor = NSColor.halo.cgColor
            clone.addSubview(buttonClone)
            self.buttonClone = buttonClone
            
            cloneField.topAnchor.constraint(equalTo: clone.topAnchor, constant: 20).isActive = true
            cloneField.leftAnchor.constraint(equalTo: clone.leftAnchor, constant: 20).isActive = true
            
            buttonClone.bottomAnchor.constraint(equalTo: clone.bottomAnchor, constant: -20).isActive = true
            buttonClone.centerXAnchor.constraint(equalTo: clone.centerXAnchor).isActive = true
            buttonClone.widthAnchor.constraint(equalToConstant: 62).isActive = true
            buttonClone.heightAnchor.constraint(equalToConstant: 22).isActive = true
        } else {
            let cloneError = Label(.local("Cloud.clone.error"))
            cloneError.textColor = NSColor(white: 1, alpha: 0.7)
            cloneError.font = .systemFont(ofSize: 16, weight: .light)
            cloneError.alignment = .center
            clone.addSubview(cloneError)
            
            cloneError.centerXAnchor.constraint(equalTo: clone.centerXAnchor).isActive = true
            cloneError.centerYAnchor.constraint(equalTo: clone.centerYAnchor).isActive = true
            cloneError.widthAnchor.constraint(lessThanOrEqualToConstant: 350).isActive = true
        }
        
        border.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 39).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        segment.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        segment.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 20).isActive = true
        
        clone.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        clone.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        clone.widthAnchor.constraint(equalTo: contentView!.widthAnchor).isActive = true
        left = clone.leftAnchor.constraint(equalTo: contentView!.leftAnchor)
        left.isActive = true
        
        pull.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        pull.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        pull.widthAnchor.constraint(equalTo: contentView!.widthAnchor).isActive = true
        pull.leftAnchor.constraint(equalTo: clone.rightAnchor).isActive = true
        
        push.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        push.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        push.widthAnchor.constraint(equalTo: contentView!.widthAnchor).isActive = true
        push.leftAnchor.constraint(equalTo: pull.rightAnchor).isActive = true
        
        loading.centerYAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -31).isActive = true
        loading.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        DispatchQueue.main.async { [weak self] in self?.clone()  }
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
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy: Selector) -> Bool {
        if doCommandBy == #selector(NSResponder.insertNewline(_:)) {
            if control == cloneField.field {
                makeClone()
                return true
            }
        }
        return false
    }
    
    private func show(_ item: Int) {
        segment.selectedSegment = item
        left.constant = contentView!.frame.width * -CGFloat(item)
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.6
            $0.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
        }) { }
    }
    
    @objc func clone() { show(0) }
    @objc func pull() { show(1) }
    @objc func push() { show(2) }
    @objc private func choose() { show(segment.selectedSegment) }
    
    @objc private func makeClone() {
        makeFirstResponder(nil)
        buttonClone.isHidden = true
        segment.isEnabled = false
        loading.isHidden = false
        Hub.clone(cloneField.field.stringValue, local: Hub.session.url, error: { [weak self] in
            app.alert(.local("Alert.error"), message: $0.localizedDescription)
            self?.buttonClone.isHidden = false
            self?.segment.isEnabled = true
            self?.loading.isHidden = true
        }) { [weak self] in
            app.alert(.local("Alert.success"), message: .local("Cloud.clone.success"))
            self?.close()
            app.browsed($0)
        }
    }
}
