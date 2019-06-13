import UIKit
import UserNotifications

class Alert {
    /*
    private weak var view: UIView?
    private weak var bottom: NSLayoutConstraint?
    private var alert = [(String, String)]()
    
    func error(_ message: String) { show(.local("Alert.error"), message: message) }
    func commit(_ message: String) { show(.local("Alert.commit"), message: message) }
    func update(_ message: String) { show(.local("Alert.update"), message: message) }
    
    private func show(_ title: String, message: String) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] in
                if $0.authorizationStatus == .authorized {
                    self?.notify(title, message: message)
                } else {
                    self?.fallback(title, message: message)
                }
            }
        } else {
            fallback(title, message: message)
        }
    }
    
    @available(iOS 10.0, *) private func notify(_ title: String, message: String) {
        UNUserNotificationCenter.current().add({
            $0.title = title
            $0.body = message
            return UNNotificationRequest(identifier: UUID().uuidString, content: $0, trigger: nil)
        } (UNMutableNotificationContent()))
    }
    
    private func fallback(_ title: String, message: String) {
        alert.append((title, message))
        if view == nil {
            DispatchQueue.main.async { [weak self] in self?.pop() }
        }
    }
    
    private func pop() {
        guard !alert.isEmpty else { return }
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(remove), for: .touchUpInside)
        view.setTitleColor(UIColor(white: 0, alpha: 0.8), for: .normal)
        view.setTitleColor(UIColor(white: 0, alpha: 0.2), for: .highlighted)
        view.titleLabel!.font = .systemFont(ofSize: 14, weight: .medium)
        view.setTitle({ "\($0.0): \($0.1)" } (alert.removeFirst()), for: [])
        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
        view.layer.cornerRadius = 4
        view.alpha = 0
        App.view.view.addSubview(view)
        self.view = view
        
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        view.leftAnchor.constraint(equalTo: App.view.view.leftAnchor, constant: 20).isActive = true
        view.rightAnchor.constraint(equalTo: App.view.view.rightAnchor, constant: -20).isActive = true
        bottom = view.bottomAnchor.constraint(equalTo: App.view.view.topAnchor)
        bottom!.isActive = true
        
        App.view.view.layoutIfNeeded()
        bottom!.constant = 55
        
        UIView.animate(withDuration: 0.6, animations: {
            view.alpha = 1
            App.view.view.layoutIfNeeded()
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self, weak view] in
                if view != nil && view === self?.view {
                    self?.remove()
                }
            }
        }
    }
    
    @objc private func remove() {
        bottom?.constant = 0
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            self?.view?.alpha = 0
            App.view.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.view?.removeFromSuperview()
            self?.pop()
        }
    }
    */
}

