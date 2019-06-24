import UIKit

final class Create: Sheet, UITextFieldDelegate {
    private let result: ((URL?) -> Void)
    private weak var name: UITextField!
    
    init(_ result: @escaping((URL?) -> Void)) {
        self.result = result
        super.init()
        let name = UITextField()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.tintColor = .halo
        name.textColor = .white
        name.delegate = self
        name.font = .systemFont(ofSize: 18, weight: .medium)
        name.autocorrectionType = .no
        name.autocapitalizationType = .none
        name.spellCheckingType = .no
        name.clearButtonMode = .never
        name.keyboardAppearance = .dark
        name.keyboardType = .alphabet
        name.textAlignment = .center
        base.addSubview(name)
        self.name = name
        
        let border = UIView()
        border.isUserInteractionEnabled = true
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        base.addSubview(border)
        
        let create = Button.Yes(.local("Create.save"))
        create.addTarget(self, action: #selector(self.create), for: .touchUpInside)
        base.addSubview(create)
        
        let cancel = Button.No(.local("Create.cancel"))
        cancel.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        base.addSubview(cancel)
        
        name.topAnchor.constraint(equalTo: base.topAnchor, constant: 20).isActive = true
        name.heightAnchor.constraint(equalToConstant: 50).isActive = true
        name.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 20).isActive = true
        name.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -20).isActive = true
        
        border.topAnchor.constraint(equalTo: name.bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 20).isActive = true
        border.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -20).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        create.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
        create.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        cancel.topAnchor.constraint(equalTo: create.bottomAnchor, constant: 20).isActive = true
        cancel.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        cancel.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -20).isActive = true
        
        name.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func textFieldShouldReturn(_: UITextField) -> Bool {
        name.resignFirstResponder()
        return true
    }
    
    @objc private func create() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name.text!.isEmpty ? .local("Create.untitled") : name.text!)
        FileManager.default.createFile(atPath: url.path, contents: Data("\n".utf8))
        result(url)
        close()
    }
    
    @objc private func cancel() {
        result(nil)
        close()
    }
}
