import Git
import UIKit

final class Reset: UIView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImageView(image: UIImage(named: "error"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        addSubview(image)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = {
            $0.append(NSAttributedString(string: .local("Reset.title"), attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: UIColor.white]))
            $0.append(NSAttributedString(string: .local("Reset.subtitle"), attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .light), .foregroundColor: UIColor(white: 1, alpha: 0.7)]))
            return $0
        } (NSMutableAttributedString())
        addSubview(label)
        
        let confirm = UIButton()
        confirm.translatesAutoresizingMaskIntoConstraints = false
        confirm.setTitle(.local("Reset.confirm"), for: [])
        confirm.titleLabel!.font = .systemFont(ofSize: 11, weight: .medium)
        confirm.setTitleColor(.black, for: .normal)
        confirm.setTitleColor(.init(white: 1, alpha: 0.2), for: .highlighted)
        confirm.layer.cornerRadius = 4
        confirm.backgroundColor = .halo
        confirm.addTarget(self, action: #selector(self.confirm), for: .touchUpInside)
        addSubview(confirm)
        
        image.topAnchor.constraint(equalTo: topAnchor, constant: 100).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 60).isActive = true
        image.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        confirm.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        confirm.widthAnchor.constraint(equalToConstant: 68).isActive = true
        confirm.heightAnchor.constraint(equalToConstant: 28).isActive = true
        confirm.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc private func confirm() {
        app.repository?.reset({
            app.alert(.local("Alert.error"), message: $0.localizedDescription)
        }) { app.alert(.local("Alert.success"), message: .local("Reset.success")) }
    }
}
