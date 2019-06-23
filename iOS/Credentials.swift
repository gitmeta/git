import Git
import UIKit

final class Credentials: Sheet, UITextFieldDelegate {
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
            field.leftAnchor.constraint(equalTo: leftAnchor, constant: 70).isActive = true
            field.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private weak var user: Field!
    private weak var password: Field!
    
    @discardableResult init() {
        super.init(350)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .local("Settings.labelKey")
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .halo
        base.addSubview(label)
        
        let user = Field()
        user.field.delegate = self
        user.field.keyboardType = .emailAddress
        user.label.text = .local("Settings.keyUser")
        user.field.text = Hub.session.user
        base.addSubview(user)
        self.user = user
        
        let password = Field()
        password.field.delegate = self
        password.field.keyboardType = .alphabet
        password.field.isSecureTextEntry = true
        password.label.text = .local("Settings.keyPassword")
        password.field.text = Hub.session.password
        base.addSubview(password)
        self.password = password
        
        let save = Button.Yes(.local("Settings.keySave"))
        save.addTarget(self, action: #selector(self.save), for: .touchUpInside)
        base.addSubview(save)
        
        let close = Button.No(.local("Settings.close"))
        close.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        base.addSubview(close)
        
        label.topAnchor.constraint(equalTo: base.topAnchor, constant: 50).isActive = true
        label.leftAnchor.constraint(equalTo: base.centerXAnchor, constant: -150).isActive = true
        
        user.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
        user.widthAnchor.constraint(equalToConstant: 300).isActive = true
        user.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        password.topAnchor.constraint(equalTo: user.bottomAnchor, constant: 20).isActive = true
        password.widthAnchor.constraint(equalToConstant: 300).isActive = true
        password.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        save.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        save.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 40).isActive = true
        
        close.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        close.topAnchor.constraint(equalTo: save.bottomAnchor, constant: 20).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func textFieldShouldReturn(_ field: UITextField) -> Bool {
        if field == user.field {
            password.field.becomeFirstResponder()
        } else {
            field.resignFirstResponder()
        }
        return true
    }
    
    @objc private func save() {
        app.window!.endEditing(true)
        Hub.session.update(user.field.text!, password: password.field.text!) { [weak self] in
            app.alert(.local("Alert.success"), message: .local("Settings.keySuccess"))
            self?.close()
        }
    }
}
