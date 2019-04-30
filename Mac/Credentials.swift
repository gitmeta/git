import Git
import AppKit

class Credentials: Sheet, NSTextFieldDelegate {
    private weak var name: NSTextField!
    private weak var email: NSTextField!
    
    @discardableResult override init() {
        super.init()
        layer!.backgroundColor = NSColor.shade.cgColor
        let title = Label(.local("Credentials.title"))
        title.font = .bold(18)
        title.textColor = .halo
        title.alignment = .center
        addSubview(title)
        
        let nameBackground = NSView()
        nameBackground.translatesAutoresizingMaskIntoConstraints = false
        nameBackground.wantsLayer = true
        nameBackground.layer!.backgroundColor = NSColor(white: 0, alpha: 0.4).cgColor
        nameBackground.layer!.cornerRadius = 4
        addSubview(nameBackground)
        
        let name = NSTextField()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.isBezeled = false
        name.font = .light(18)
        name.focusRingType = .none
        name.drawsBackground = false
        name.textColor = .white
        name.maximumNumberOfLines = 1
        name.lineBreakMode = .byTruncatingHead
        name.placeholderString = .local("Credentials.name")
        name.stringValue = App.session.name
        name.delegate = self
        addSubview(name)
        (name.window?.fieldEditor(true, for: name) as? NSTextView)?.insertionPointColor = .halo
        self.name = name
        
        let emailBackground = NSView()
        emailBackground.translatesAutoresizingMaskIntoConstraints = false
        emailBackground.wantsLayer = true
        emailBackground.layer!.backgroundColor = NSColor(white: 0, alpha: 0.4).cgColor
        emailBackground.layer!.cornerRadius = 4
        addSubview(emailBackground)
        
        let email = NSTextField()
        email.translatesAutoresizingMaskIntoConstraints = false
        email.isBezeled = false
        email.font = .light(18)
        email.focusRingType = .none
        email.drawsBackground = false
        email.textColor = .white
        email.maximumNumberOfLines = 1
        email.lineBreakMode = .byTruncatingHead
        email.placeholderString = .local("Credentials.email")
        email.stringValue = App.session.email
        email.delegate = self
        addSubview(email)
        (email.window?.fieldEditor(true, for: email) as? NSTextView)?.insertionPointColor = .halo
        self.email = email
        
        let confirm = Button(.local("Credentials.confirm"), target: self, action: #selector(self.confirm))
        confirm.layer!.backgroundColor = NSColor.halo.cgColor
        addSubview(confirm)
        
        let cancel = Button(.local("Credentials.cancel"),
                            color: NSColor(white: 1, alpha: 0.5), target: self, action: #selector(close))
        addSubview(cancel)
        
        title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        title.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -80).isActive = true
        
        name.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        name.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 40).isActive = true
        name.widthAnchor.constraint(equalToConstant: 280).isActive = true
        name.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameBackground.topAnchor.constraint(equalTo: name.topAnchor, constant: -10).isActive = true
        nameBackground.bottomAnchor.constraint(equalTo: name.bottomAnchor).isActive = true
        nameBackground.leftAnchor.constraint(equalTo: name.leftAnchor, constant: -8).isActive = true
        nameBackground.rightAnchor.constraint(equalTo: name.rightAnchor, constant: 8).isActive = true
        
        email.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        email.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 14).isActive = true
        email.widthAnchor.constraint(equalToConstant: 280).isActive = true
        email.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        emailBackground.topAnchor.constraint(equalTo: email.topAnchor, constant: -10).isActive = true
        emailBackground.bottomAnchor.constraint(equalTo: email.bottomAnchor).isActive = true
        emailBackground.leftAnchor.constraint(equalTo: email.leftAnchor, constant: -8).isActive = true
        emailBackground.rightAnchor.constraint(equalTo: email.rightAnchor, constant: 8).isActive = true
        
        confirm.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        confirm.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 40).isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cancel.topAnchor.constraint(equalTo: confirm.bottomAnchor, constant: 20).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak name] in
            App.window.makeFirstResponder(name)
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy: Selector) -> Bool {
        if (doCommandBy == #selector(NSResponder.insertNewline(_:)) || doCommandBy == #selector(NSResponder.insertTab(_:))) {
            if control == name {
                App.window.makeFirstResponder(email)
            } else {
                confirm()
            }
            return true
        }
        return false
    }
    
    @objc private func confirm() {
        App.window.makeFirstResponder(nil)
        do {
            let user = try User(name.stringValue, email: email.stringValue)
            App.session.name = user.name
            App.session.email = user.email
            Git.update(App.session)
            close()
        } catch {
            App.window.alert.error(error.localizedDescription)
        }
    }
}
