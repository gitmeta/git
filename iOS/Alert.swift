import UIKit

final class Alert: UIView {
    @discardableResult init(_ message: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        backgroundColor = .shade
        layer.cornerRadius = 8
        layer.borderColor = UIColor.halo.cgColor
        layer.borderWidth = 1
        alpha = 0
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        addSubview(label)
        
        app.view.addSubview(self)
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        leftAnchor.constraint(equalTo: app.view.leftAnchor, constant: 4).isActive = true
        rightAnchor.constraint(equalTo: app.view.rightAnchor, constant: -4).isActive = true
        let top = topAnchor.constraint(equalTo: app.view.topAnchor, constant: -60)
        top.isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        app.view.layoutIfNeeded()
        top.constant = 30
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.alpha = 1
            app.view.layoutIfNeeded()
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                top.constant = -90
                UIView.animate(withDuration: 0.5, animations: { [weak self] in
                    self?.alpha = 0
                    app.view.layoutIfNeeded()
                }, completion: { [weak self] _ in
                    self?.removeFromSuperview()
                })
            }
        }
    }
    
    required init?(coder: NSCoder) { return nil }
}
