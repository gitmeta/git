import UIKit

final class Credentials: Sheet, UITextFieldDelegate {
    final class Field: UIView {
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
    
    var done: ((String, String) -> Void)!
    private(set) weak var title: UILabel!
    private(set) weak var first: Field!
    private(set) weak var second: Field!
    
    @discardableResult override init() {
        super.init()
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 14, weight: .regular)
        title.textColor = .halo
        base.addSubview(title)
        self.title = title
        
        let first = Field()
        first.field.delegate = self
        base.addSubview(first)
        self.first = first
        
        let second = Field()
        second.field.delegate = self
        base.addSubview(second)
        self.second = second
        
        let save = Button.Yes(.local("Settings.keySave"))
        save.addTarget(self, action: #selector(self.save), for: .touchUpInside)
        base.addSubview(save)
        
        let close = Button.No(.local("Settings.close"))
        close.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        base.addSubview(close)
        
        title.topAnchor.constraint(equalTo: base.topAnchor, constant: 50).isActive = true
        title.leftAnchor.constraint(equalTo: base.centerXAnchor, constant: -150).isActive = true
        
        first.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        first.widthAnchor.constraint(equalToConstant: 300).isActive = true
        first.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        second.topAnchor.constraint(equalTo: first.bottomAnchor, constant: 20).isActive = true
        second.widthAnchor.constraint(equalToConstant: 300).isActive = true
        second.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        
        save.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        save.topAnchor.constraint(equalTo: second.bottomAnchor, constant: 40).isActive = true
        
        close.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        close.topAnchor.constraint(equalTo: save.bottomAnchor, constant: 20).isActive = true
        close.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -20).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func textFieldShouldReturn(_ field: UITextField) -> Bool {
        if field == first.field {
            second.field.becomeFirstResponder()
        } else {
            field.resignFirstResponder()
        }
        return true
    }
    
    override func close() {
        super.close()
        done = nil
    }
    
    @objc private func save() {
        app.window!.endEditing(true)
        done(first.field.text!, second.field.text!)
    }
}
