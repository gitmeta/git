import UIKit

final class Create: UIView, UITextFieldDelegate {
    private let result: ((URL?) -> Void)
    private weak var name: UITextField!
    
    init(_ result: @escaping((URL?) -> Void)) {
        self.result = result
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .init(white: 0, alpha: 0.9)
        alpha = 0
        
        let name = UITextField()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.tintColor = .halo
        name.textColor = .white
        name.backgroundColor = .black
        name.layer.cornerRadius = 6
        name.layer.borderColor = UIColor.halo.cgColor
        name.layer.borderWidth = 1
        name.delegate = self
        name.font = .systemFont(ofSize: 18, weight: .medium)
        name.autocorrectionType = .no
        name.autocapitalizationType = .none
        name.spellCheckingType = .no
        name.clearButtonMode = .never
        name.keyboardAppearance = .dark
        name.keyboardType = .alphabet
        name.textAlignment = .center
        addSubview(name)
        self.name = name
        
        let create = Button.Yes(.local("Create.save"))
        create.addTarget(self, action: #selector(self.create), for: .touchUpInside)
        addSubview(create)
        
        let cancel = Button.No(.local("Create.cancel"))
        cancel.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        addSubview(cancel)
        
        name.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        name.heightAnchor.constraint(equalToConstant: 50).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        name.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        
        create.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 30).isActive = true
        create.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        cancel.topAnchor.constraint(equalTo: create.bottomAnchor, constant: 30).isActive = true
        cancel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = 1
        }) { [weak name] _ in name?.becomeFirstResponder() }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func textFieldShouldReturn(_: UITextField) -> Bool {
        name.resignFirstResponder()
        return true
    }
    
    private func finish(_ url: URL?) {
        app.window!.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = 0
        }) { [weak self] _ in
            self?.result(url)
            self?.removeFromSuperview()
        }
    }
    
    @objc private func create() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name.text!.isEmpty ? .local("Create.untitled") : name.text!)
        FileManager.default.createFile(atPath: url.path, contents: nil)
        finish(url)
    }
    
    @objc private func cancel() { finish(nil) }
}
