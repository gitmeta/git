import Git
import AppKit

final class Settings: Window, NSTextFieldDelegate {
    private final class Field: NSView {
        private(set) weak var field: NSTextField!
        private(set) weak var label: Label!
        
        required init?(coder: NSCoder) { return nil }
        init(_ type: NSTextField.Type = NSTextField.self) {
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
            border.layer!.backgroundColor = NSColor.halo.cgColor
            addSubview(border)
            
            let field = type.init()
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
    }
    
    private weak var buttonKey: Button.Yes!
    private weak var buttonSign: Button.Yes!
    private weak var signName: Field!
    private weak var signEmail: Field!
    private weak var keyUser: Field!
    private weak var keyPassword: Field!
    private weak var left: NSLayoutConstraint!
    
    init() {
        super.init(320, 300)
        let buttonSign = Button.Yes(self, action: #selector(sign))
        buttonSign.label.stringValue = .key("Settings.buttonSign")
        contentView!.addSubview(buttonSign)
        self.buttonSign = buttonSign
        
        let buttonKey = Button.Yes(self, action: #selector(key))
        buttonKey.label.stringValue = .key("Settings.buttonKey")
        contentView!.addSubview(buttonKey)
        self.buttonKey = buttonKey
        
        let sign = NSView()
        sign.translatesAutoresizingMaskIntoConstraints = false
        contentView!.addSubview(sign)
        
        let key = NSView()
        key.translatesAutoresizingMaskIntoConstraints = false
        contentView!.addSubview(key)
        
        let labelSign = Label(.key("Settings.labelSign"))
        labelSign.font = .systemFont(ofSize: 14, weight: .light)
        labelSign.textColor = .halo
        sign.addSubview(labelSign)
        
        let signName = Field()
        signName.field.delegate = self
        signName.label.stringValue = .key("Settings.signName")
        signName.field.stringValue = Hub.session.name
        (fieldEditor(true, for: signName.field) as? NSTextView)?.insertionPointColor = .halo
        sign.addSubview(signName)
        self.signName = signName
        
        let signEmail = Field()
        signEmail.field.delegate = self
        signEmail.label.stringValue = .key("Settings.signEmail")
        signEmail.field.stringValue = Hub.session.email
        (fieldEditor(true, for: signEmail.field) as? NSTextView)?.insertionPointColor = .halo
        sign.addSubview(signEmail)
        self.signEmail = signEmail
        
        let signSave = Button.Yes(self, action: #selector(self.signSave))
        signSave.label.stringValue = .key("Settings.signSave")
        sign.addSubview(signSave)
        
        let labelKey = Label(.key("Settings.labelKey"))
        labelKey.font = .systemFont(ofSize: 14, weight: .light)
        labelKey.textColor = .halo
        key.addSubview(labelKey)
        
        let keyUser = Field()
        keyUser.field.delegate = self
        keyUser.label.stringValue = .key("Settings.keyUser")
        keyUser.field.stringValue = Hub.session.user
        (fieldEditor(true, for: keyUser.field) as? NSTextView)?.insertionPointColor = .halo
        key.addSubview(keyUser)
        self.keyUser = keyUser
        
        let keyPassword = Field(NSSecureTextField.self)
        keyPassword.field.delegate = self
        keyPassword.label.stringValue = .key("Settings.keyPassword")
        keyPassword.field.stringValue = Hub.session.password
        (fieldEditor(true, for: keyPassword.field) as? NSTextView)?.insertionPointColor = .halo
        key.addSubview(keyPassword)
        self.keyPassword = keyPassword
        
        let keySave = Button.Yes(self, action: #selector(self.keySave))
        keySave.label.stringValue = .key("Settings.keySave")
        key.addSubview(keySave)
        
        buttonKey.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        buttonKey.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 20).isActive = true
        buttonKey.width.constant = 100
        
        buttonSign.rightAnchor.constraint(equalTo: buttonKey.leftAnchor, constant: -5).isActive = true
        buttonSign.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 20).isActive = true
        buttonSign.width.constant = 100
        
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
        labelSign.leftAnchor.constraint(equalTo: sign.leftAnchor, constant: 18).isActive = true
        
        signName.topAnchor.constraint(equalTo: labelSign.bottomAnchor, constant: 20).isActive = true
        signName.leftAnchor.constraint(equalTo: sign.leftAnchor, constant: 20).isActive = true
        
        signEmail.topAnchor.constraint(equalTo: signName.bottomAnchor, constant: 20).isActive = true
        signEmail.leftAnchor.constraint(equalTo: sign.leftAnchor, constant: 20).isActive = true
        
        signSave.bottomAnchor.constraint(equalTo: sign.bottomAnchor, constant: -20).isActive = true
        signSave.centerXAnchor.constraint(equalTo: sign.centerXAnchor).isActive = true
        
        labelKey.topAnchor.constraint(equalTo: key.topAnchor, constant: 20).isActive = true
        labelKey.leftAnchor.constraint(equalTo: key.leftAnchor, constant: 18).isActive = true
        
        keyUser.topAnchor.constraint(equalTo: labelKey.bottomAnchor, constant: 20).isActive = true
        keyUser.leftAnchor.constraint(equalTo: key.leftAnchor, constant: 20).isActive = true
        
        keyPassword.topAnchor.constraint(equalTo: keyUser.bottomAnchor, constant: 20).isActive = true
        keyPassword.leftAnchor.constraint(equalTo: key.leftAnchor, constant: 20).isActive = true
        
        keySave.bottomAnchor.constraint(equalTo: key.bottomAnchor, constant: -20).isActive = true
        keySave.centerXAnchor.constraint(equalTo: key.centerXAnchor).isActive = true
        
        DispatchQueue.main.async { [weak self] in self?.sign()  }
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy: Selector) -> Bool {
        if doCommandBy == #selector(NSResponder.insertNewline(_:)) {
            if control == signName.field {
                makeFirstResponder(signEmail.field)
            } else if control == signEmail.field {
                signSave()
            } else if control == keyUser.field {
                makeFirstResponder(keyPassword.field)
            } else {
                keySave()
            }
            return true
        } else if doCommandBy == #selector(NSResponder.insertTab(_:)) || doCommandBy == #selector(NSResponder.insertBacktab(_:)) {
            if control == signName.field {
                makeFirstResponder(signEmail.field)
            } else if control == signEmail.field {
                makeFirstResponder(signName.field)
            } else if control == keyUser.field {
                makeFirstResponder(keyPassword.field)
            } else if control == keyPassword.field {
                makeFirstResponder(keyUser.field)
            }
            return true
        } else if doCommandBy == #selector(NSResponder.cancelOperation(_:)) {
            makeFirstResponder(nil)
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
            buttonSign.layer!.backgroundColor = NSColor.halo.cgColor
            buttonKey.layer!.backgroundColor = .clear
            buttonSign.label.textColor = .black
            buttonKey.label.textColor = .halo
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
            buttonKey.layer!.backgroundColor = NSColor.halo.cgColor
            buttonSign.label.textColor = .halo
            buttonKey.label.textColor = .black
        }) { }
    }
    
    @objc private func signSave() {
        makeFirstResponder(nil)
        Hub.session.update(signName.field.stringValue, email: signEmail.field.stringValue, error: {
            app.alert(.key("Alert.error"), message: $0.localizedDescription)
        }) { app.alert(.key("Alert.success"), message: .key("Settings.signSuccess")) }
    }
    
    @objc private func keySave() {
        makeFirstResponder(nil)
        Hub.session.update(keyUser.field.stringValue, password: keyPassword.field.stringValue) {
            app.alert(.key("Alert.success"), message: .key("Settings.keySuccess"))
        }
    }
}
