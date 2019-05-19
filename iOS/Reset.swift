import Git
import UIKit

class Reset: Sheet {
    @discardableResult override init() {
        super.init()
        let image = UIImageView(image: #imageLiteral(resourceName: "error.pdf"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        addSubview(image)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = {
            $0.append(NSAttributedString(string: .local("Reset.title"), attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold),
                                                                                     .foregroundColor: UIColor.white]))
            $0.append(NSAttributedString(string: .local("Reset.subtitle"), attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .light),
                                                                                        .foregroundColor: UIColor(white: 1, alpha: 0.6)]))
            return $0
        } (NSMutableAttributedString())
        addSubview(label)
        
        let confirm = UIButton()
        confirm.translatesAutoresizingMaskIntoConstraints = false
        confirm.addTarget(self, action: #selector(self.confirm), for: .touchUpInside)
        confirm.setTitle(.local("Reset.confirm"), for: [])
        confirm.setTitleColor(.black, for: .normal)
        confirm.setTitleColor(UIColor(white: 0, alpha: 0.2), for: .highlighted)
        confirm.titleLabel!.font = .systemFont(ofSize: 14, weight: .medium)
        confirm.backgroundColor = .halo
        confirm.layer.cornerRadius = 6
        addSubview(confirm)
        
        let cancel = UIButton()
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        cancel.setTitle(.local("Reset.cancel"), for: [])
        cancel.setTitleColor(.white, for: .normal)
        cancel.setTitleColor(UIColor(white: 1, alpha: 0.2), for: .highlighted)
        cancel.titleLabel!.font = .systemFont(ofSize: 14, weight: .medium)
        addSubview(cancel)
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        
        confirm.widthAnchor.constraint(equalToConstant: 90).isActive = true
        confirm.heightAnchor.constraint(equalToConstant: 32).isActive = true
        confirm.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        confirm.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -20).isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        if #available(iOS 11.0, *) {
            cancel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        } else {
            cancel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc private func confirm() {
        close()
        App.repository?.reset({
            App.view.alert.error($0.localizedDescription)
        }) {
            App.view.alert.update(.local("Reset.success"))
            App.view.refresh()
        }
    }
}
