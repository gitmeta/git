import Git
import UIKit

final class Signature: UIView, UITextFieldDelegate {
    private final class Field: UIView {
        private(set) weak var field: UITextField!
        private(set) weak var label: UILabel!
        
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 12, weight: .bold)
            label.textColor = .halo
            addSubview(label)
            self.label = label
            
            let border = UIView()
            border.isUserInteractionEnabled = false
            border.translatesAutoresizingMaskIntoConstraints = false
            border.backgroundColor = .halo
            addSubview(border)
            
            let field = UITextField()
            field.translatesAutoresizingMaskIntoConstraints = false
            field.borderStyle = .none
            field.clearButtonMode = .never
            field.font = .systemFont(ofSize: 16, weight: .regular)
            field.backgroundColor = .clear
            field.textColor = .white
            field.autocorrectionType = .no
            field.autocapitalizationType = .none
            field.spellCheckingType = .no
            field.keyboardAppearance = .dark
            field.tintColor = .halo
            addSubview(field)
            self.field = field
            
            heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            field.topAnchor.constraint(equalTo: topAnchor).isActive = true
            field.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            field.leftAnchor.constraint(equalTo: leftAnchor, constant: 50).isActive = true
            field.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private weak var name: Field!
    private weak var email: Field!
    
    @discardableResult init() {
        super.init(frame: .zero)
        guard !app.view.subviews.contains(where: { $0 is Signature }) else { return }
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0
        app.view.addSubview(self)
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.isUserInteractionEnabled = false
        blur.alpha = 0.85
        addSubview(blur)
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .black
        addSubview(base)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .local("Settings.labelSign")
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .halo
        base.addSubview(label)
        
        let name = Field()
        name.field.delegate = self
        name.field.keyboardType = .alphabet
        name.label.text = .local("Settings.signName")
        name.field.text = Hub.session.name
        base.addSubview(name)
        self.name = name
        
        let email = Field()
        email.field.delegate = self
        email.field.keyboardType = .emailAddress
        email.label.text = .local("Settings.signEmail")
        email.field.text = Hub.session.email
        base.addSubview(email)
        self.email = email
        
        let save = Button.Yes(.local("Settings.signSave"))
        save.addTarget(self, action: #selector(self.save), for: .touchUpInside)
        base.addSubview(save)
        
        let close = Button.No(.local("Settings.close"))
        close.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        base.addSubview(close)
        
        blur.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blur.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blur.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        blur.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 340).isActive = true
        let top = base.topAnchor.constraint(equalTo: topAnchor, constant: -340)
        top.isActive = true
        
        topAnchor.constraint(equalTo: app.view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: app.view.bottomAnchor).isActive = true
        leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: app.view.rightAnchor).isActive = true
        
        label.topAnchor.constraint(equalTo: base.topAnchor, constant: 40).isActive = true
        label.leftAnchor.constraint(equalTo: base.centerXAnchor, constant: -150).isActive = true
        
        name.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
        name.widthAnchor.constraint(equalToConstant: 300).isActive = true
        name.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        email.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 20).isActive = true
        email.widthAnchor.constraint(equalToConstant: 300).isActive = true
        email.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        save.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        save.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 40).isActive = true
        
        close.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        close.topAnchor.constraint(equalTo: save.bottomAnchor, constant: 20).isActive = true
        
        app.view.layoutIfNeeded()
        
        top.constant = 0
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.alpha = 1
            self?.layoutIfNeeded()
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func textFieldShouldReturn(_ field: UITextField) -> Bool {
        if field == name.field {
            email.field.becomeFirstResponder()
        } else {
            field.resignFirstResponder()
        }
        return true
    }
    
    @objc private func save() {
        app.window!.endEditing(true)
        Hub.session.update(name.field.text!, email: email.field.text!, error: {
            app.alert(.local("Alert.error"), message: $0.localizedDescription)
        }) { [weak self] in
            app.alert(.local("Alert.success"), message: .local("Settings.signSuccess"))
            self?.close()
        }
    }
    
    @objc private func close() {
        app.window!.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = 0
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
}
