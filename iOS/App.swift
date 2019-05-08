import Git
import UIKit
import StoreKit

@UIApplicationMain class App: UIWindow, UIApplicationDelegate {
    private(set) static weak var shared: App!
    static let view = View()
    private weak var branch: Bar!
    
    private(set) static var repository: Repository? {
        didSet {
            view.branch.label.text = repository?.branch ?? ""
            if repository == nil {
                view.notRepository()
                view.list.update([])
            } else {
                view.refresh()
                repository!.status = {
                    if $0.isEmpty {
                        view.upToDate()
                    } else {
                        view.repository()
                    }
                    view.list.update($0)
                }
            }
        }
    }
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        App.shared = self
        rootViewController = App.view
        makeKeyAndVisible()
        return true
    }
    
    func load() {
        Hub.session.load {
            Hub.session.update(
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0], bookmark: Data()) {
                if let expected = UserDefaults.standard.value(forKey: "rating") as? Date {
                    if Date() >= expected {
                        var components = DateComponents()
                        components.month = 4
                        UserDefaults.standard.setValue(Calendar.current.date(byAdding: components, to: Date())!, forKey: "rating")
                        if #available(iOS 10.3, *) { SKStoreReviewController.requestReview() }
                    }
                } else {
                    var components = DateComponents()
                    components.day = 3
                    UserDefaults.standard.setValue(Calendar.current.date(byAdding: components, to: Date())!, forKey: "rating")
                    Onboard()
                }
                Hub.open(Hub.session.url, error: { _ in
                    App.repository = nil
                }) { App.repository = $0 }
            }
        }
    }
    
    @objc func create() {
        Hub.create(Hub.session.url, error: {
            App.view.alert.error($0.localizedDescription)
        }) { App.repository = $0 }
    }
}
