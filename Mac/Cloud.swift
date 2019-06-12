import Git
import AppKit

final class Cloud: NSWindow, NSTextFieldDelegate {
    private final class Field: NSView {
        private(set) weak var field: NSTextField!
        private(set) weak var button: Button.Text!
        
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let label = Label(.local("Cloud.field"))
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.textColor = .halo
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
            field.refusesFirstResponder = true
            if #available(OSX 10.12.2, *) {
                field.isAutomaticTextCompletionEnabled = false
            }
            addSubview(field)
            self.field = field
            
            let button = Button.Text(nil, action: nil)
            button.label.font = .systemFont(ofSize: 11, weight: .medium)
            button.label.textColor = .black
            button.wantsLayer = true
            button.layer!.cornerRadius = 4
            button.layer!.backgroundColor = NSColor.halo.cgColor
            addSubview(button)
            self.button = button
            
            widthAnchor.constraint(equalToConstant: 460).isActive = true
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 2).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            field.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            field.heightAnchor.constraint(equalToConstant: 30).isActive = true
            field.leftAnchor.constraint(equalTo: leftAnchor, constant: 60).isActive = true
            field.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
            
            button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 62).isActive = true
            button.heightAnchor.constraint(equalToConstant: 22).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private weak var clonning: Field?
    private weak var pulling: Field?
    private weak var pushing: Field?
    private weak var segment: NSSegmentedControl!
    private weak var left: NSLayoutConstraint!
    private weak var loading: NSImageView!
    
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
        segment.selectedSegment = 0
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
            let clonning = Field()
            clonning.button.target = self
            clonning.button.action = #selector(makeClone)
            clonning.button.label.stringValue = .local("Cloud.clone.button")
            clonning.field.delegate = self
            clone.addSubview(clonning)
            self.clonning = clonning
            
            let pullError = Label(.local("Cloud.pull.error"))
            pullError.textColor = NSColor(white: 1, alpha: 0.7)
            pullError.font = .systemFont(ofSize: 16, weight: .light)
            pull.addSubview(pullError)
            
            let pushError = Label(.local("Cloud.push.error"))
            pushError.textColor = NSColor(white: 1, alpha: 0.7)
            pushError.font = .systemFont(ofSize: 16, weight: .light)
            push.addSubview(pushError)
            
            clonning.topAnchor.constraint(equalTo: clone.topAnchor, constant: 20).isActive = true
            clonning.leftAnchor.constraint(equalTo: clone.leftAnchor, constant: 20).isActive = true
            clonning.bottomAnchor.constraint(equalTo: clone.bottomAnchor, constant: -20).isActive = true
            
            pullError.centerXAnchor.constraint(equalTo: pull.centerXAnchor).isActive = true
            pullError.centerYAnchor.constraint(equalTo: pull.centerYAnchor).isActive = true
            
            pushError.centerXAnchor.constraint(equalTo: push.centerXAnchor).isActive = true
            pushError.centerYAnchor.constraint(equalTo: push.centerYAnchor).isActive = true
        } else {
            let cloneError = Label(.local("Cloud.clone.error"))
            cloneError.textColor = NSColor(white: 1, alpha: 0.7)
            cloneError.font = .systemFont(ofSize: 16, weight: .light)
            cloneError.alignment = .center
            clone.addSubview(cloneError)
            
            let pulling = Field()
            pulling.button.target = self
            pulling.button.action = #selector(makePull)
            pulling.button.label.stringValue = .local("Cloud.pull.button")
            pulling.field.delegate = self
            pull.addSubview(pulling)
            self.pulling = pulling
            
            let pushing = Field()
            pushing.button.target = self
            pushing.button.action = #selector(makePush)
            pushing.button.label.stringValue = .local("Cloud.push.button")
            pushing.field.delegate = self
            push.addSubview(pushing)
            self.pushing = pushing
            
            cloneError.centerXAnchor.constraint(equalTo: clone.centerXAnchor).isActive = true
            cloneError.centerYAnchor.constraint(equalTo: clone.centerYAnchor).isActive = true
            cloneError.widthAnchor.constraint(lessThanOrEqualToConstant: 350).isActive = true
            
            pulling.topAnchor.constraint(equalTo: pull.topAnchor, constant: 20).isActive = true
            pulling.leftAnchor.constraint(equalTo: pull.leftAnchor, constant: 20).isActive = true
            pulling.bottomAnchor.constraint(equalTo: pull.bottomAnchor, constant: -20).isActive = true
            
            pushing.topAnchor.constraint(equalTo: push.topAnchor, constant: 20).isActive = true
            pushing.leftAnchor.constraint(equalTo: push.leftAnchor, constant: 20).isActive = true
            pushing.bottomAnchor.constraint(equalTo: push.bottomAnchor, constant: -20).isActive = true
            
            app.repository?.remote { [weak self] in
                var remote = $0
                if remote.hasPrefix("https://") {
                    remote.removeFirst(8)
                }
                self?.pulling!.field.stringValue = remote
                self?.pushing!.field.stringValue = remote
            }
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
            makeFirstResponder(nil)
            return true
        } else if doCommandBy == #selector(NSResponder.cancelOperation(_:)) {
            makeFirstResponder(nil)
            return true
        }
        return false
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if pulling?.field == obj.object as? NSTextField {
            app.repository!.remote(pulling!.field.stringValue)
            pushing!.field.stringValue = pulling!.field.stringValue
        } else if pushing?.field == obj.object as? NSTextField {
            app.repository!.remote(pushing!.field.stringValue)
            pulling!.field.stringValue = pushing!.field.stringValue
        }
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
    
    @objc func clone() {
        makeFirstResponder(clonning?.field)
        show(0)
    }
    
    @objc func pull() { show(1) }
    @objc func push() { show(2) }
    
    @objc private func choose() {
        show(segment.selectedSegment)
        switch segment.selectedSegment {
        case 0: makeFirstResponder(clonning?.field)
        default: break
        }
    }
    
    @objc private func makeClone() {
        makeFirstResponder(nil)
        clonning!.button.isHidden = true
        segment.isEnabled = false
        loading.isHidden = false
        clonning!.field.isEditable = false
        Hub.clone(clonning!.field.stringValue, local: Hub.session.url, error: { [weak self] in
            app.alert(.local("Alert.error"), message: $0.localizedDescription)
            self?.clonning!.button.isHidden = false
            self?.segment.isEnabled = true
            self?.loading.isHidden = true
            self?.clonning!.field.isEditable = true
        }) { [weak self] in
            app.alert(.local("Alert.success"), message: .local("Cloud.clone.success"))
            self?.close()
            app.browsed($0)
        }
    }
    
    @objc private func makePull() {
        makeFirstResponder(nil)
        pulling!.button.isHidden = true
        segment.isEnabled = false
        loading.isHidden = false
        pulling!.field.isEditable = false
        app.repository!.pull({ [weak self] in
            app.alert(.local("Alert.error"), message: $0.localizedDescription)
            self?.pulling!.button.isHidden = false
            self?.segment.isEnabled = true
            self?.loading.isHidden = true
            self?.pulling!.field.isEditable = true
        }) { [weak self] in
            app.alert(.local("Alert.success"), message: .local("Cloud.pull.success"))
            self?.close()
        }
    }
    
    @objc private func makePush() {
        makeFirstResponder(nil)
        pushing!.button.isHidden = true
        segment.isEnabled = false
        loading.isHidden = false
        pushing!.field.isEditable = false
        app.repository!.push({ [weak self] in
            app.alert(.local("Alert.error"), message: $0.localizedDescription)
            self?.pushing!.button.isHidden = false
            self?.segment.isEnabled = true
            self?.loading.isHidden = true
            self?.pushing!.field.isEditable = true
        }) { [weak self] in
            app.alert(.local("Alert.success"), message: .local("Cloud.push.success"))
            self?.close()
        }
    }
}
