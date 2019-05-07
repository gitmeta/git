import UIKit

@UIApplicationMain class App: UIWindow, UIApplicationDelegate {
    static private(set) weak var shared: App!
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        App.shared = self
        makeKeyAndVisible()
        try! "hello world\n".write(to: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("file.txt"), atomically: true, encoding: .utf8)
        home()
        return true
    }
    
    func browser() {
        if #available(iOS 11.0, *) {
            let browse = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: nil)
            browse.browserUserInterfaceStyle = .dark
            rootViewController = browse
        }
    }
    
    func home() {
        rootViewController = View()
    }
}
