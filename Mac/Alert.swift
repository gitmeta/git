import AppKit
import UserNotifications

class Alert {
    private weak var view: NSView?
    private weak var bottom: NSLayoutConstraint?
    private var alert = [(String, String)]()
    
    func error(_ message: String) { show(.local("Alert.error"), message: message) }
    func commit(_ message: String) { show(.local("Alert.commit"), message: message) }
    
    private func show(_ title: String, message: String) {
        if #available(OSX 10.14, *) {
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
    
    @available(OSX 10.14, *) private func notify(_ title: String, message: String) {
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
        let view = Button.Text(self, action: #selector(remove))
        view.label.textColor = .halo
        view.label.font = .systemFont(ofSize: 14, weight: .medium)
        view.label.stringValue = { "\($0.0): \($0.1)" } (alert.removeFirst())
        view.wantsLayer = true
        view.layer!.backgroundColor = NSColor(white: 0, alpha: 0.9).cgColor
        view.layer!.cornerRadius = 4
        view.alphaValue = 0
        view.height.constant = 40
        view.width.constant = App.window.contentView!.frame.width - 20
        App.window.contentView!.addSubview(view)
        self.view = view
        
        view.leftAnchor.constraint(equalTo:App.window.contentView!.leftAnchor, constant: 10).isActive = true
        bottom = view.bottomAnchor.constraint(equalTo: App.window.contentView!.topAnchor)
        bottom!.isActive = true
        
        App.window.contentView!.layoutSubtreeIfNeeded()
        bottom!.constant = 70
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.6
            $0.allowsImplicitAnimation = true
            view.alphaValue = 1
            App.window.contentView!.layoutSubtreeIfNeeded()
        }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self, weak view] in
                if view != nil && view === self?.view {
                    self?.remove()
                }
            }
        }
    }
    
    @objc private func remove() {
        bottom?.constant = 0
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.6
            $0.allowsImplicitAnimation = true
            view?.alphaValue = 0
            App.window.contentView!.layoutSubtreeIfNeeded()
        }) { [weak self] in
            self?.view?.removeFromSuperview()
            self?.pop()
        }
    }
}
