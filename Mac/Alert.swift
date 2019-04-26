import AppKit
import UserNotifications

class Alert {
    func show(_ message: String) {
//        DispatchQueue.main.async { [weak self] in
//            if #available(OSX 10.14, *) {
//                self?.notify(message)
//            } else {
//                self?.fallback(message)
//            }
//        }
    }
    
    @available(OSX 10.14, *) private func notify(_ message: String) {
        UNUserNotificationCenter.current().add({
            $0.body = message
            return UNNotificationRequest(identifier: UUID().uuidString, content: $0, trigger: nil)
        } (UNMutableNotificationContent()))
    }
    
    private func fallback(_ message: String) {
        NSUserNotificationCenter.default.deliver({
            $0.identifier = UUID().uuidString
            $0.informativeText = message
            return $0
        } (NSUserNotification()))
    }
}
