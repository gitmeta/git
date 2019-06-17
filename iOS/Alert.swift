import UIKit

final class Alert: UIView {
    @discardableResult init(_ message: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        backgroundColor = .init(white: 0, alpha: 0.7)
        layer.cornerRadius = 8
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        alpha = 0
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        addSubview(label)
        
        app.view.addSubview(self)
        
        heightAnchor.constraint(equalToConstant: 90).isActive = true
        leftAnchor.constraint(equalTo: app.view.leftAnchor, constant: 20).isActive = true
        rightAnchor.constraint(equalTo: app.view.rightAnchor, constant: -20).isActive = true
        let top = topAnchor.constraint(equalTo: app.view.topAnchor, constant: -90)
        top.isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        app.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            top.constant = 120
            self?.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                UIView.animate(withDuration: 0.5, animations: { [weak self] in
                    self?.alpha = 0
                    top.constant = -90
                }, completion: { [weak self] _ in
                    self?.removeFromSuperview()
                })
            }
        }
    }
    
    required init?(coder: NSCoder) { return nil }
}
