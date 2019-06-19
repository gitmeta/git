import Git
import UIKit

final class Reset: UIView {
    @discardableResult init() {
        super.init(frame: .zero)
        guard !app.view.subviews.contains(where: { $0 is Signature }) else { return }
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.shade.withAlphaComponent(0.95)
        alpha = 0
        app.view.addSubview(self)
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .black
        base.layer.cornerRadius = 6
        addSubview(base)
        
        let image = UIImageView(image: UIImage(named: "error"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        base.addSubview(image)
        
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = {
            $0.append(NSAttributedString(string: .local("Reset.title"), attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: UIColor.white]))
            $0.append(NSAttributedString(string: .local("Reset.subtitle"), attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .light), .foregroundColor: UIColor(white: 1, alpha: 0.7)]))
            return $0
        } (NSMutableAttributedString())
        base.addSubview(label)
        
        let confirm = UIButton()
        confirm.translatesAutoresizingMaskIntoConstraints = false
        confirm.setTitle(.local("Reset.confirm"), for: [])
        confirm.titleLabel!.font = .systemFont(ofSize: 11, weight: .medium)
        confirm.setTitleColor(.black, for: .normal)
        confirm.setTitleColor(.init(white: 1, alpha: 0.2), for: .highlighted)
        confirm.layer.cornerRadius = 4
        confirm.backgroundColor = .halo
        confirm.addTarget(self, action: #selector(self.confirm), for: .touchUpInside)
        base.addSubview(confirm)
        
        let cancel = UIButton()
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.setTitle(.local("Reset.cancel"), for: [])
        cancel.titleLabel!.font = .systemFont(ofSize: 11, weight: .medium)
        cancel.setTitleColor(.init(white: 1, alpha: 0.6), for: .normal)
        cancel.setTitleColor(.init(white: 1, alpha: 0.2), for: .highlighted)
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        base.addSubview(cancel)
        
        topAnchor.constraint(equalTo: app.view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: app.view.bottomAnchor).isActive = true
        leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: app.view.rightAnchor).isActive = true
        
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        base.heightAnchor.constraint(equalToConstant: 310).isActive = true
        let top = base.topAnchor.constraint(equalTo: topAnchor, constant: -290)
        top.isActive = true
        
        image.topAnchor.constraint(equalTo: base.topAnchor, constant: 60).isActive = true
        image.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 60).isActive = true
        image.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        label.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        confirm.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        confirm.widthAnchor.constraint(equalToConstant: 68).isActive = true
        confirm.heightAnchor.constraint(equalToConstant: 28).isActive = true
        confirm.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        cancel.topAnchor.constraint(equalTo: confirm.bottomAnchor, constant: 20).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 68).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        app.view.layoutIfNeeded()
        
        top.constant = -20
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.alpha = 1
            self?.layoutIfNeeded()
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc private func confirm() {
        app.repository?.reset({
            app.alert(.local("Alert.error"), message: $0.localizedDescription)
        }) { app.alert(.local("Alert.success"), message: .local("Reset.success")) }
    }
    
    @objc private func close() {
        app.window!.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = 0
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
}
