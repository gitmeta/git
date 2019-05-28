import Git
import AppKit

class Settings: NSWindow, NSTextFieldDelegate {
    private class Field: NSView {
        private(set) weak var field: NSTextField!
        private(set) weak var label: Label!
        
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let label = Label()
            label.font = .systemFont(ofSize: 12, weight: .bold)
            label.textColor = .halo
            addSubview(label)
            self.label = label
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
            addSubview(border)
            
            let field = NSTextField()
            field.translatesAutoresizingMaskIntoConstraints = false
            field.isBezeled = false
            field.font = .systemFont(ofSize: 14, weight: .regular)
            field.focusRingType = .none
            field.drawsBackground = false
            field.textColor = .white
            field.maximumNumberOfLines = 1
            field.lineBreakMode = .byTruncatingHead
            if #available(OSX 10.12.2, *) {
                field.isAutomaticTextCompletionEnabled = false
            }
            addSubview(field)
            (field.window?.fieldEditor(true, for: field) as? NSTextView)?.insertionPointColor = .halo
            self.field = field
            
            widthAnchor.constraint(equalToConstant: 280).isActive = true
            heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            field.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 5).isActive = true
            field.heightAnchor.constraint(equalToConstant: 30).isActive = true
            field.leftAnchor.constraint(equalTo: leftAnchor, constant: 80).isActive = true
            field.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private weak var buttonKey: Button.Text!
    private weak var buttonSign: Button.Text!
    private weak var signName: Field!
    private weak var signEmail: Field!
    private weak var left: NSLayoutConstraint!
    
    init() {
        super.init(contentRect: NSRect(
            x: app.home.frame.minX + 50, y: app.home.frame.maxY - 400, width: 320, height: 350),
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
        
        let buttonSign = Button.Text(self, action: #selector(sign))
        buttonSign.label.stringValue = .local("Settings.buttonSign")
        buttonSign.label.font = .systemFont(ofSize: 11, weight: .medium)
        buttonSign.wantsLayer = true
        buttonSign.layer!.cornerRadius = 4
        contentView!.addSubview(buttonSign)
        self.buttonSign = buttonSign
        
        let buttonKey = Button.Text(self, action: #selector(key))
        buttonKey.label.stringValue = .local("Settings.buttonKey")
        buttonKey.label.font = .systemFont(ofSize: 11, weight: .medium)
        buttonKey.wantsLayer = true
        buttonKey.layer!.cornerRadius = 4
        contentView!.addSubview(buttonKey)
        self.buttonKey = buttonKey
        
        let sign = NSView()
        sign.translatesAutoresizingMaskIntoConstraints = false
        contentView!.addSubview(sign)
        
        let key = NSView()
        key.translatesAutoresizingMaskIntoConstraints = false
        contentView!.addSubview(key)
        
        let labelSign = Label(.local("Settings.labelSign"))
        labelSign.font = .systemFont(ofSize: 14, weight: .light)
        labelSign.textColor = NSColor(white: 1, alpha: 0.6)
        sign.addSubview(labelSign)
        
        let signName = Field()
        signName.field.delegate = self
        signName.label.stringValue = .local("Settings.signName")
        signName.field.stringValue = Hub.session.name
        sign.addSubview(signName)
        self.signName = signName
        
        let signEmail = Field()
        signEmail.field.delegate = self
        signEmail.label.stringValue = .local("Settings.signEmail")
        signEmail.field.stringValue = Hub.session.email
        sign.addSubview(signEmail)
        self.signEmail = signEmail
        
        let signSave = Button.Text(self, action: #selector(self.signSave))
        signSave.label.stringValue = .local("Settings.signSave")
        signSave.label.font = .systemFont(ofSize: 11, weight: .medium)
        signSave.label.textColor = .black
        signSave.wantsLayer = true
        signSave.layer!.cornerRadius = 4
        signSave.layer!.backgroundColor = NSColor.halo.cgColor
        sign.addSubview(signSave)
        
        border.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 39).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        buttonKey.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        buttonKey.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 20).isActive = true
        buttonKey.widthAnchor.constraint(equalToConstant: 100).isActive = true
        buttonKey.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        buttonSign.rightAnchor.constraint(equalTo: buttonKey.leftAnchor, constant: -5).isActive = true
        buttonSign.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 20).isActive = true
        buttonSign.widthAnchor.constraint(equalToConstant: 100).isActive = true
        buttonSign.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        sign.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        sign.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        sign.widthAnchor.constraint(equalTo: contentView!.widthAnchor).isActive = true
        left = sign.leftAnchor.constraint(equalTo: contentView!.leftAnchor)
        left.isActive = true
        
        key.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        key.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        key.widthAnchor.constraint(equalTo: contentView!.widthAnchor).isActive = true
        key.leftAnchor.constraint(equalTo: sign.rightAnchor).isActive = true
        
        labelSign.topAnchor.constraint(equalTo: sign.topAnchor, constant: 20).isActive = true
        labelSign.leftAnchor.constraint(equalTo: sign.leftAnchor, constant: 20).isActive = true
        
        signName.topAnchor.constraint(equalTo: labelSign.bottomAnchor, constant: 20).isActive = true
        signName.leftAnchor.constraint(equalTo: sign.leftAnchor, constant: 20).isActive = true
        
        signEmail.topAnchor.constraint(equalTo: signName.bottomAnchor, constant: 20).isActive = true
        signEmail.leftAnchor.constraint(equalTo: sign.leftAnchor, constant: 20).isActive = true
        
        signSave.bottomAnchor.constraint(equalTo: sign.bottomAnchor, constant: -20).isActive = true
        signSave.centerXAnchor.constraint(equalTo: sign.centerXAnchor).isActive = true
        signSave.widthAnchor.constraint(equalToConstant: 62).isActive = true
        signSave.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        DispatchQueue.main.async { [weak self] in self?.sign()  }
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy: Selector) -> Bool {
        if doCommandBy == #selector(NSResponder.insertNewline(_:)) {
            if control == signName.field {
                makeFirstResponder(signEmail.field)
            } else if control == signEmail.field {
                signSave()
            }
            return true
        } else if doCommandBy == #selector(NSResponder.insertTab(_:)) || doCommandBy == #selector(NSResponder.insertBacktab(_:)) {
            if control == signName.field {
                makeFirstResponder(signEmail.field)
            } else if control == signEmail.field {
                makeFirstResponder(signName.field)
            }
            return true
        }
        return false
    }
    
    @objc func sign() {
        makeFirstResponder(nil)
        left.constant = 0
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.6
            $0.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            buttonSign.layer!.backgroundColor = NSColor(white: 1, alpha: 0.6).cgColor
            buttonKey.layer!.backgroundColor = .clear
            buttonSign.label.textColor = .black
            buttonKey.label.textColor = NSColor(white: 1, alpha: 0.5)
        }) { }
    }
    
    @objc func key() {
        makeFirstResponder(nil)
        left.constant = -contentView!.frame.width
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.6
            $0.allowsImplicitAnimation = true
            contentView!.layoutSubtreeIfNeeded()
            buttonSign.layer!.backgroundColor = .clear
            buttonKey.layer!.backgroundColor = NSColor(white: 1, alpha: 0.6).cgColor
            buttonSign.label.textColor = NSColor(white: 1, alpha: 0.5)
            buttonKey.label.textColor = .black
        }) { }
    }
    
    @objc private func signSave() {
        makeFirstResponder(nil)
        Hub.session.update(signName.field.stringValue, email: signEmail.field.stringValue, error: {
            app.alert.error($0.localizedDescription)
        }) { app.alert.update(.local("Settings.signSuccess")) }
    }
}
