import Git
import AppKit
import UserNotifications

@NSApplicationMain class App: NSWindow, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    private(set) static var shared: App!
    private(set) var url: URL?
    private(set) var repository: Repository?
    private weak var bar: Bar!
    private weak var list: List!
    private weak var directory: Button!
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
    override func cancelOperation(_: Any?) { makeFirstResponder(nil) }
    override func mouseDown(with: NSEvent) { makeFirstResponder(nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        App.shared = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
        backgroundColor = .black
        NSApp.delegate = self
        
        let bar = Bar()
        bar.isHidden = true
        contentView!.addSubview(bar)
        self.bar = bar
        
        let list = List()
        list.isHidden = true
        contentView!.addSubview(list)
        self.list = list
        
        let directory = Button(.local("App.directory"), target: self, action: #selector(self.prompt))
        directory.isHidden = true
        directory.layer!.backgroundColor = NSColor.warning.cgColor
        directory.width.constant = 120
        contentView!.addSubview(directory)
        self.directory = directory
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 5).isActive = true
        bar.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 72).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -5).isActive = true
        
        list.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 5).isActive = true
        list.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        
        directory.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        directory.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        
        if #available(OSX 10.14, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { (granted, error) in
                if granted {
                    print("Yay!")
                    let center = UNUserNotificationCenter.current()
                    center.delegate = self
                    let show = UNNotificationAction(identifier: "show", title: "Tell me more…", options: .foreground)
                    let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
                    
                    center.setNotificationCategories([category])
                } else {
                    print("D'oh")
                }
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            guard
                let url = UserDefaults.standard.url(forKey: "url"),
                let access = UserDefaults.standard.data(forKey: "access")
            else {
                DispatchQueue.main.async { directory.isHidden = false }
                return
            }
            var stale = false
            _ = (try? URL(resolvingBookmarkData: access, options: .withSecurityScope, bookmarkDataIsStale:
                &stale))?.startAccessingSecurityScopedResource()
            self.select(url)
        }
    }
    
    @objc func start() {
        if #available(OSX 10.14, *) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
        }
        /*Git.create(url!, error: {
            
        }) {
            
        }*/
    }
    
    @available(OSX 10.14, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                print("Default identifier")
                
            case "show":
                // the user tapped our "show more info…" button
                print("Show more information…")
                break
                
            default:
                break
            }
        }
        
        // you must call the completion handler when you're done
        completionHandler()
    }
    
    @available(OSX 10.14, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound]) 
    }
    
    private func select(_ url: URL) {
        self.url = url
        Git.repository(url) {
            if $0 {
                
            } else {
                
            }
        }
        DispatchQueue.main.async {
            self.bar.isHidden = false
            self.directory.isHidden = true
            self.bar.label.stringValue = url.path
            self.list.update()
        }
    }
    
    @objc private func prompt() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.begin {
            if $0 == .OK {
                DispatchQueue.global(qos: .background).async {
                    UserDefaults.standard.set(panel.url, forKey: "url")
                    UserDefaults.standard.set((try! panel.url!.bookmarkData(options: .withSecurityScope)), forKey: "access")
                    self.select(panel.url!)
                }
            }
        }
    }
}
