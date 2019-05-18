import Git
import UIKit

class Credentials: Sheet, UITextFieldDelegate {
    private weak var name: UITextField!
    private weak var email: UITextField!
    
    @discardableResult override init() {
        super.init()
        let image = UIImageView(image: #imageLiteral(resourceName: "users.pdf"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        addSubview(image)
        
        let nameTitle = UILabel()
        nameTitle.translatesAutoresizingMaskIntoConstraints = false
        nameTitle.text = .local("Credentials.name")
        nameTitle.font = .systemFont(ofSize: 14, weight: .bold)
        nameTitle.textColor = .halo
        addSubview(nameTitle)
        
        let emailTitle = UILabel()
        emailTitle.translatesAutoresizingMaskIntoConstraints = false
        emailTitle.text = .local("Credentials.email")
        emailTitle.font = .systemFont(ofSize: 14, weight: .bold)
        emailTitle.textColor = .halo
        addSubview(emailTitle)
        
        let nameBackground = UIView()
        nameBackground.isUserInteractionEnabled = false
        nameBackground.translatesAutoresizingMaskIntoConstraints = false
        nameBackground.backgroundColor = .black
        nameBackground.layer.cornerRadius = 4
        addSubview(nameBackground)
        
        let name = UITextField()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.borderStyle = .none
        name.clearButtonMode = .never
        name.font = .systemFont(ofSize: 14, weight: .regular)
        name.backgroundColor = .clear
        name.textColor = .white
        name.text = Hub.session.name
        name.autocorrectionType = .no
        name.autocapitalizationType = .none
        name.spellCheckingType = .no
        name.keyboardType = .alphabet
        name.keyboardAppearance = .dark
        name.delegate = self
        name.tintColor = .halo
        addSubview(name)
        self.name = name
        
        let emailBackground = UIView()
        emailBackground.translatesAutoresizingMaskIntoConstraints = false
        emailBackground.isUserInteractionEnabled = false
        emailBackground.backgroundColor = .black
        emailBackground.layer.cornerRadius = 4
        addSubview(emailBackground)
        
        let email = UITextField()
        email.translatesAutoresizingMaskIntoConstraints = false
        email.borderStyle = .none
        email.clearButtonMode = .never
        email.font = .systemFont(ofSize: 14, weight: .regular)
        email.backgroundColor = .clear
        email.textColor = .white
        email.text = Hub.session.email
        email.autocapitalizationType = .none
        email.autocorrectionType = .no
        email.spellCheckingType = .no
        email.keyboardType = .emailAddress
        email.keyboardAppearance = .dark
        email.tintColor = .halo
        email.delegate = self
        addSubview(email)
        self.email = email
        
        let confirm = UIButton()
        confirm.translatesAutoresizingMaskIntoConstraints = false
        confirm.addTarget(self, action: #selector(self.confirm), for: .touchUpInside)
        confirm.setTitle(.local("Credentials.confirm"), for: [])
        confirm.setTitleColor(.black, for: .normal)
        confirm.setTitleColor(UIColor(white: 0, alpha: 0.2), for: .highlighted)
        confirm.titleLabel!.font = .systemFont(ofSize: 14, weight: .medium)
        confirm.backgroundColor = .halo
        confirm.layer.cornerRadius = 6
        addSubview(confirm)
        
        let cancel = UIButton()
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        cancel.setTitle(.local("Credentials.cancel"), for: [])
        cancel.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        cancel.setTitleColor(UIColor(white: 1, alpha: 0.2), for: .highlighted)
        cancel.titleLabel!.font = .systemFont(ofSize: 12, weight: .regular)
        addSubview(cancel)
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 68).isActive = true
        image.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        name.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 20).isActive = true
        name.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 40).isActive = true
        name.widthAnchor.constraint(equalToConstant: 200).isActive = true
        name.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameBackground.topAnchor.constraint(equalTo: name.topAnchor).isActive = true
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
        email.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        emailBackground.topAnchor.constraint(equalTo: email.topAnchor).isActive = true
        emailBackground.bottomAnchor.constraint(equalTo: email.bottomAnchor).isActive = true
        emailBackground.leftAnchor.constraint(equalTo: email.leftAnchor, constant: -10).isActive = true
        emailBackground.rightAnchor.constraint(equalTo: email.rightAnchor, constant: 10).isActive = true
        
        confirm.widthAnchor.constraint(equalToConstant: 100).isActive = true
        confirm.heightAnchor.constraint(equalToConstant: 36).isActive = true
        confirm.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        confirm.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 50).isActive = true
        
        cancel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 36).isActive = true
        cancel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cancel.topAnchor.constraint(equalTo: confirm.bottomAnchor, constant: 20).isActive = true
        
        if #available(iOS 11.0, *) {
            image.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        } else {
            image.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        }
        
        ready = { [weak self] in
            self?.name.becomeFirstResponder()
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func textFieldShouldReturn(_ field: UITextField) -> Bool {
        if field === name {
            email.becomeFirstResponder()
        } else {
            confirm()
        }
        return true
    }
    
    @objc private func confirm() {
        App.shared.endEditing(true)
        Hub.session.update(name.text!, email: email.text!, error: {
            App.view.alert.error($0.localizedDescription)
        }) { [weak self] in
            App.view.alert.update(.local("Credentials.success"))
            self?.close()
        }
    }
}
