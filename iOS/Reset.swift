import Git
import UIKit

final class Reset: Sheet {
    @discardableResult override init() {
        super.init()
        let image = UIImageView(image: UIImage(named: "error"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        base.addSubview(image)
        
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.attributedText = {
            $0.append(NSAttributedString(string: .local("Reset.title"), attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold)]))
            $0.append(NSAttributedString(string: .local("Reset.subtitle"), attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .light)]))
            return $0
        } (NSMutableAttributedString())
        base.addSubview(label)
        
        let confirm = Button.Yes(.local("Reset.confirm"))
        confirm.addTarget(self, action: #selector(self.confirm), for: .touchUpInside)
        base.addSubview(confirm)
        
        let cancel = Button.No(.local("Reset.cancel"))
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        base.addSubview(cancel)
        
        image.topAnchor.constraint(equalTo: base.topAnchor, constant: 40).isActive = true
        image.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 60).isActive = true
        image.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        label.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 260).isActive = true
        
        confirm.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        confirm.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        cancel.topAnchor.constraint(equalTo: confirm.bottomAnchor, constant: 20).isActive = true
        cancel.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -20).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc private func confirm() {
        app.repository?.reset({
            app.alert(.local("Alert.error"), message: $0.localizedDescription)
        }) { [weak self] in
            app.alert(.local("Alert.success"), message: .local("Reset.success"))
            self?.close()
        }
    }
}
