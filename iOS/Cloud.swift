import Git
import UIKit

final class Cloud: Sheet, UITextFieldDelegate {
    private weak var field: UITextField!
    private weak var loading: UIImageView!
    private weak var button: Button.Yes!
    private weak var cancel: Button.No!
    override var height: CGFloat { return 220 }
    
    @discardableResult override init() {
        super.init()
        let border = UIView()
        border.isUserInteractionEnabled = true
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        base.addSubview(border)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .halo
        label.text = .local("Cloud.field")
        base.addSubview(label)
        
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.tintColor = .white
        field.textColor = .white
        field.delegate = self
        field.font = .systemFont(ofSize: 15, weight: .regular)
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.spellCheckingType = .no
        field.clearButtonMode = .never
        field.keyboardAppearance = .dark
        field.keyboardType = .URL
        base.addSubview(field)
        self.field = field
        
        let button = Button.Yes(app.repository == nil ? .local("Cloud.clone.button") : .local("Cloud.synch.button"))
        button.addTarget(self, action: #selector(make), for: .touchUpInside)
        base.addSubview(button)
        self.button = button
        
        let cancel = Button.No(.local("Cloud.cancel"))
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        base.addSubview(cancel)
        self.cancel = cancel
        
        let loading = UIImageView(image: UIImage(named: "loading"))
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.clipsToBounds = true
        loading.contentMode = .center
        loading.isHidden = true
        base.addSubview(loading)
        self.loading = loading
        
        label.topAnchor.constraint(equalTo: field.topAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 20).isActive = true
        label.heightAnchor.constraint(equalTo: field.heightAnchor).isActive = true
        
        field.topAnchor.constraint(equalTo: base.topAnchor, constant: 50).isActive = true
        field.heightAnchor.constraint(equalToConstant: 50).isActive = true
        field.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 70).isActive = true
        field.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -20).isActive = true
        
        border.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 20).isActive = true
        border.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -20).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        button.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
        button.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        loading.widthAnchor.constraint(equalToConstant: 100).isActive = true
        loading.heightAnchor.constraint(equalToConstant: 40).isActive = true
        loading.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
        cancel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20).isActive = true
        cancel.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        app.repository?.remote { [weak self] in self?.field.text = $0 }
    }
    
    required init?(coder: NSCoder) { return nil }
    func textFieldDidEndEditing(_: UITextField) { app.repository?.remote(field.text!) }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        field.resignFirstResponder()
        return true
    }
    
    private func ready() {
        button.isHidden = false
        loading.isHidden = true
        field.isEnabled = true
    }
    
    @objc private func make() {
        field.resignFirstResponder()
        button.isHidden = true
        loading.isHidden = false
        field.isEnabled = false
        if app.repository == nil {
            Hub.clone(field.text!, local: Hub.session.url, error: { [weak self] in
                app.alert(.local("Alert.error"), message: $0.localizedDescription)
                self?.ready()
            }) { [weak self] _ in
                app.alert(.local("Alert.success"), message: .local("Cloud.clone.success"))
                self?.close()
            }
        } else {
            app.repository!.pull({ [weak self] in
                app.alert(.local("Alert.error"), message: $0.localizedDescription)
                self?.ready()
            }) { [weak self] in
                app.repository!.push({ [weak self] in
                    app.alert(.local("Alert.error"), message: $0.localizedDescription)
                    self?.ready()
                }) { [weak self] in
                    app.alert(.local("Alert.success"), message: .local("Cloud.synch.success"))
                    self?.close()
                }
            }
        }
    }
}
