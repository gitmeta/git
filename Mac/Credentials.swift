import Git
import AppKit

class Credentials: Sheet, NSTextFieldDelegate {
    private weak var name: NSTextField!
    private weak var email: NSTextField!
    
    @discardableResult override init() {
        super.init()
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = NSImage(named: "users")
        image.imageScaling = .scaleNone
        addSubview(image)
        
        let nameTitle = Label(.local("Credentials.name"))
        nameTitle.font = .systemFont(ofSize: 14, weight: .bold)
        nameTitle.textColor = .halo
        addSubview(nameTitle)
        
        let emailTitle = Label(.local("Credentials.email"))
        emailTitle.font = .systemFont(ofSize: 14, weight: .bold)
        emailTitle.textColor = .halo
        addSubview(emailTitle)
        
        let nameBackground = NSView()
        nameBackground.translatesAutoresizingMaskIntoConstraints = false
        nameBackground.wantsLayer = true
        nameBackground.layer!.backgroundColor = NSColor.black.cgColor
        nameBackground.layer!.cornerRadius = 4
        addSubview(nameBackground)
        
        let name = NSTextField()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.isBezeled = false
        name.font = .systemFont(ofSize: 14, weight: .regular)
        name.focusRingType = .none
        name.drawsBackground = false
        name.textColor = .white
        name.maximumNumberOfLines = 1
        name.lineBreakMode = .byTruncatingHead
        name.stringValue = Hub.session.name
        name.delegate = self
        addSubview(name)
        (name.window?.fieldEditor(true, for: name) as? NSTextView)?.insertionPointColor = .halo
        self.name = name
        
        let emailBackground = NSView()
        emailBackground.translatesAutoresizingMaskIntoConstraints = false
        emailBackground.wantsLayer = true
        emailBackground.layer!.backgroundColor = NSColor.black.cgColor
        emailBackground.layer!.cornerRadius = 4
        addSubview(emailBackground)
        
        let email = NSTextField()
        email.translatesAutoresizingMaskIntoConstraints = false
        email.isBezeled = false
        email.font = .systemFont(ofSize: 15, weight: .regular)
        email.focusRingType = .none
        email.drawsBackground = false
        email.textColor = .white
        email.maximumNumberOfLines = 1
        email.lineBreakMode = .byTruncatingHead
        email.stringValue = Hub.session.email
        email.delegate = self
        addSubview(email)
        (email.window?.fieldEditor(true, for: email) as? NSTextView)?.insertionPointColor = .halo
        self.email = email
        
        let confirm = Button.Text(self, action: #selector(self.confirm))
        confirm.label.textColor = .black
        confirm.label.font = .systemFont(ofSize: 14, weight: .medium)
        confirm.label.stringValue = .local("Credentials.confirm")
        confirm.wantsLayer = true
        confirm.layer!.backgroundColor = NSColor.halo.cgColor
        confirm.layer!.cornerRadius = 6
//        confirm.width.constant = 70
//        confirm.height.constant = 28
        addSubview(confirm)
        
        let cancel = Button.Text(self, action: #selector(close))
        cancel.label.textColor = NSColor(white: 1, alpha: 0.7)
        cancel.label.font = .systemFont(ofSize: 12, weight: .regular)
        cancel.label.stringValue = .local("Credentials.cancel")
//        cancel.width.constant = 70
//        cancel.height.constant = 28
        addSubview(cancel)
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -80).isActive = true
        
        name.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 20).isActive = true
        name.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 60).isActive = true
        name.widthAnchor.constraint(equalToConstant: 200).isActive = true
        name.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        nameBackground.topAnchor.constraint(equalTo: name.topAnchor, constant: -12).isActive = true
        nameBackground.bottomAnchor.constraint(equalTo: name.bottomAnchor).isActive = true
        nameBackground.leftAnchor.constraint(equalTo: name.leftAnchor, constant: -10).isActive = true
        nameBackground.rightAnchor.constraint(equalTo: name.rightAnchor, constant: 10).isActive = true
        
        nameTitle.rightAnchor.constraint(equalTo: nameBackground.leftAnchor, constant: -10).isActive = true
        nameTitle.centerYAnchor.constraint(equalTo: nameBackground.centerYAnchor).isActive = true
        
        emailTitle.rightAnchor.constraint(equalTo: emailBackground.leftAnchor, constant: -10).isActive = true
        emailTitle.centerYAnchor.constraint(equalTo: emailBackground.centerYAnchor).isActive = true
        
        email.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 20).isActive = true
        email.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 14).isActive = true
        email.widthAnchor.constraint(equalToConstant: 200).isActive = true
        email.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        emailBackground.topAnchor.constraint(equalTo: email.topAnchor, constant: -12).isActive = true
        emailBackground.bottomAnchor.constraint(equalTo: email.bottomAnchor).isActive = true
        emailBackground.leftAnchor.constraint(equalTo: email.leftAnchor, constant: -10).isActive = true
        emailBackground.rightAnchor.constraint(equalTo: email.rightAnchor, constant: 10).isActive = true
        
        confirm.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        confirm.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 60).isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cancel.topAnchor.constraint(equalTo: confirm.bottomAnchor, constant: 10).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak name] in
            app.home.makeFirstResponder(name)
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy: Selector) -> Bool {
        if doCommandBy == #selector(NSResponder.insertNewline(_:)) {
            if control == name {
                app.home.makeFirstResponder(email)
            } else {
                confirm()
            }
            return true
        } else if doCommandBy == #selector(NSResponder.insertTab(_:)) || doCommandBy == #selector(NSResponder.insertBacktab(_:)) {
            if control == name {
                app.home.makeFirstResponder(email)
            } else {
                app.home.makeFirstResponder(name)
            }
            return true
        }
        return false
    }
    
    @objc private func confirm() {
        app.home.makeFirstResponder(nil)
        Hub.session.update(name.stringValue, email: email.stringValue, error: {
            app.alert.error($0.localizedDescription)
        }) { [weak self] in
            app.alert.update(.local("Credentials.success"))
            self?.close()
        }
    }
}
