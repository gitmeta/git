import UIKit

class Create: UIViewController, UITextFieldDelegate {
    private let result: ((URL?) -> Void)
    private weak var name: UITextField!
    
    init(_ result: @escaping((URL?) -> Void)) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .shade
        
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = .black
        view.addSubview(background)
        
        let name = UITextField()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.tintColor = .halo
        name.textColor = .halo
        name.delegate = self
        name.font = .systemFont(ofSize: 24, weight: .medium)
        name.autocorrectionType = .no
        name.autocapitalizationType = .none
        name.spellCheckingType = .no
        name.clearButtonMode = .never
        name.keyboardAppearance = .dark
        name.keyboardType = .alphabet
        name.textAlignment = .center
        view.addSubview(name)
        self.name = name
        
        let create = UIButton()
        create.addTarget(self, action: #selector(self.create), for: .touchUpInside)
        create.translatesAutoresizingMaskIntoConstraints = false
        create.layer.cornerRadius = 20
        create.backgroundColor = .halo
        create.setTitleColor(.black, for: .normal)
        create.setTitleColor(UIColor(white: 0, alpha: 0.2), for: .highlighted)
        create.setTitle(.local("Create.save"), for: [])
        create.titleLabel!.font = .systemFont(ofSize: 14, weight: .medium)
        create.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(create)
        
        let cancel = UIButton()
        cancel.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.layer.cornerRadius = 20
        cancel.backgroundColor = .halo
        cancel.setTitleColor(.black, for: .normal)
        cancel.setTitleColor(UIColor(white: 0, alpha: 0.2), for: .highlighted)
        cancel.setTitle(.local("Create.cancel"), for: [])
        cancel.titleLabel!.font = .systemFont(ofSize: 14, weight: .medium)
        cancel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancel)
        
        background.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        background.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        background.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: name.bottomAnchor).isActive = true

        name.heightAnchor.constraint(equalToConstant: 60).isActive = true
        name.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        name.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        create.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 20).isActive = true
        create.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -100).isActive = true
        create.widthAnchor.constraint(equalToConstant: 270).isActive = true
        create.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        cancel.topAnchor.constraint(equalTo: create.bottomAnchor, constant: 20).isActive = true
        cancel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -100).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 270).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        if #available(iOS 11.0, *) {
            name.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            name.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        name.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_: UITextField) -> Bool {
        name.resignFirstResponder()
        return true
    }
    
    @objc private func create() {
//        App.shared.endEditing(true)
//        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name.text!.isEmpty ?
//            .local("Create.untitled") : name.text!)
//        FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
//        result(url)
    }
    
    @objc private func cancel() {
//        App.shared.endEditing(true)
//        result(nil)
    }
}
