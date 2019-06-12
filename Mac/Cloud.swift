import Git
import AppKit

final class Cloud: NSWindow, NSTextFieldDelegate {
    private weak var field: NSTextField!
    private weak var loading: NSImageView!
    private var buttons = [Button]()
    
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
        
        let title = Label(.local("Cloud.title"))
        title.textColor = .halo
        title.font = .systemFont(ofSize: 14, weight: .bold)
        contentView!.addSubview(title)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        contentView!.addSubview(border)
        
        let label = Label(.local("Cloud.field"))
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .halo
        contentView!.addSubview(label)
        
        let textBorder = NSView()
        textBorder.translatesAutoresizingMaskIntoConstraints = false
        textBorder.wantsLayer = true
        textBorder.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
        contentView!.addSubview(textBorder)
        
        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isBezeled = false
        field.font = .systemFont(ofSize: 15, weight: .regular)
        field.focusRingType = .none
        field.drawsBackground = false
        field.textColor = .white
        field.maximumNumberOfLines = 1
        field.lineBreakMode = .byTruncatingHead
        field.delegate = self
        if #available(OSX 10.12.2, *) {
            field.isAutomaticTextCompletionEnabled = false
        }
        contentView!.addSubview(field)
        self.field = field
        
        let loading = NSImageView()
        loading.image = NSImage(named: "loading")
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.imageScaling = .scaleNone
        loading.isHidden = true
        contentView!.addSubview(loading)
        self.loading = loading
        
        if app.repository == nil {
            let button = Button.Text(self, action: #selector(clone))
            button.label.font = .systemFont(ofSize: 11, weight: .medium)
            button.label.textColor = .black
            button.wantsLayer = true
            button.layer!.cornerRadius = 4
            button.layer!.backgroundColor = NSColor.halo.cgColor
            button.label.stringValue = .local("Cloud.clone.button")
            contentView!.addSubview(button)
            buttons = [button]
            
            button.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -20).isActive = true
            button.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 62).isActive = true
            button.heightAnchor.constraint(equalToConstant: 22).isActive = true
        } else {
            field.refusesFirstResponder = true
            
            let pull = Button.Text(self, action: #selector(self.pull))
            pull.label.font = .systemFont(ofSize: 11, weight: .medium)
            pull.label.textColor = .black
            pull.wantsLayer = true
            pull.layer!.cornerRadius = 4
            pull.layer!.backgroundColor = NSColor.halo.cgColor
            pull.label.stringValue = .local("Cloud.pull.button")
            contentView!.addSubview(pull)
            
            let push = Button.Text(self, action: #selector(self.push))
            push.label.font = .systemFont(ofSize: 11, weight: .medium)
            push.label.textColor = .black
            push.wantsLayer = true
            push.layer!.cornerRadius = 4
            push.layer!.backgroundColor = NSColor.halo.cgColor
            push.label.stringValue = .local("Cloud.push.button")
            contentView!.addSubview(push)
            buttons = [pull, push]
            
            pull.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -20).isActive = true
            pull.rightAnchor.constraint(equalTo: contentView!.centerXAnchor, constant: -10).isActive = true
            pull.widthAnchor.constraint(equalToConstant: 62).isActive = true
            pull.heightAnchor.constraint(equalToConstant: 22).isActive = true
            
            push.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -20).isActive = true
            push.leftAnchor.constraint(equalTo: contentView!.centerXAnchor, constant: 10).isActive = true
            push.widthAnchor.constraint(equalToConstant: 62).isActive = true
            push.heightAnchor.constraint(equalToConstant: 22).isActive = true
            
            app.repository?.remote { [weak self] in self?.field.stringValue = $0 }
        }
        
        title.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 18).isActive = true
        title.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -20).isActive = true
        
        label.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 24).isActive = true
        label.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 20).isActive = true
        
        textBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true
        textBorder.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 2).isActive = true
        textBorder.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 20).isActive = true
        textBorder.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -20).isActive = true
        
        field.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 25).isActive = true
        field.heightAnchor.constraint(equalToConstant: 30).isActive = true
        field.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 80).isActive = true
        field.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -34).isActive = true
        
        border.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 39).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
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
    
    func controlTextDidEndEditing(_: Notification) { app.repository?.remote(field.stringValue) }
    
    private func busy() {
        makeFirstResponder(nil)
        buttons.forEach { $0.isHidden = true }
        loading.isHidden = false
        field.isEditable = false
    }
    
    private func ready() {
        buttons.forEach { $0.isHidden = false }
        loading.isHidden = true
        field.isEditable = true
    }
    
    @objc private func clone() {
        busy()
        Hub.clone(field.stringValue, local: Hub.session.url, error: { [weak self] in
            app.alert(.local("Alert.error"), message: $0.localizedDescription)
            self?.ready()
        }) { [weak self] in
            app.alert(.local("Alert.success"), message: .local("Cloud.clone.success"))
            self?.close()
            app.browsed($0)
        }
    }
    
    @objc private func pull() {
        busy()
        app.repository!.pull({ [weak self] in
            app.alert(.local("Alert.error"), message: $0.localizedDescription)
            self?.ready()
        }) { [weak self] in
            app.alert(.local("Alert.success"), message: .local("Cloud.pull.success"))
            self?.close()
        }
    }
    
    @objc private func push() {
        busy()
        app.repository!.push({ [weak self] in
            app.alert(.local("Alert.error"), message: $0.localizedDescription)
            self?.ready()
        }) { [weak self] in
            app.alert(.local("Alert.success"), message: .local("Cloud.push.success"))
            self?.close()
        }
    }
}
