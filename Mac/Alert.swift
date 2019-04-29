import AppKit
import UserNotifications

class Alert {
    func error(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            if #available(OSX 10.14, *) {
                self?.notify(.local("Alert.error"), message: message)
            } else {
                self?.fallback(.local("Alert.error"), message: message)
            }
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
        NSUserNotificationCenter.default.deliver({
            $0.title = title
            $0.identifier = UUID().uuidString
            $0.informativeText = message
            return $0
        } (NSUserNotification()))
    }
}
