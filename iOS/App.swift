import Git
import UIKit

@UIApplicationMain class App: UIWindow, UIApplicationDelegate, UIDocumentBrowserViewControllerDelegate {
    static private(set) weak var shared: App!
    private weak var branch: Bar!
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        App.shared = self
        makeKeyAndVisible()
        rootViewController = UIViewController()
        
        let display = Display()
        rootViewController!.view.addSubview(display)
        
        let location = Bar.Location()
        location.addTarget(self, action: #selector(browser), for: .touchUpInside)
        rootViewController!.view.addSubview(location)
        
        let branch = Bar.Branch()
        rootViewController!.view.addSubview(branch)
        self.branch = branch
        
        display.topAnchor.constraint(equalTo: rootViewController!.view.topAnchor).isActive = true
        display.bottomAnchor.constraint(equalTo: rootViewController!.view.bottomAnchor).isActive = true
        display.leftAnchor.constraint(equalTo: rootViewController!.view.leftAnchor).isActive = true
        display.rightAnchor.constraint(equalTo: rootViewController!.view.rightAnchor).isActive = true
        
        location.leftAnchor.constraint(equalTo: rootViewController!.view.leftAnchor, constant: 10).isActive = true
        
        branch.topAnchor.constraint(equalTo: location.topAnchor).isActive = true
        branch.leftAnchor.constraint(equalTo: location.rightAnchor, constant: -16).isActive = true
        branch.rightAnchor.constraint(equalTo: rootViewController!.view.rightAnchor, constant: -10).isActive = true
        
        if #available(iOS 11.0, *) {
            location.topAnchor.constraint(equalTo: rootViewController!.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        } else {
            location.topAnchor.constraint(equalTo: rootViewController!.view.topAnchor, constant: 10).isActive = true
        }
        
        Hub.session.load {
            if Hub.session.bookmark.isEmpty {
                //                Onboard()
            } else {
                
            }
        }
        return true
    }
    
    @available(iOS 11.0, *) func documentBrowser(_: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler:
        @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        rootViewController!.presentedViewController!.present(Create { [weak self] url in
            self?.rootViewController!.presentedViewController?.dismiss(animated: true) {
                didRequestDocumentCreationWithHandler(url, url == nil ? .none : .move)
            }
        }, animated: true)
    }
    
    @available(iOS 11.0, *) func documentBrowser(_: UIDocumentBrowserViewController, didPickDocumentsAt: [URL]) {
        let share = UIActivityViewController(activityItems: didPickDocumentsAt, applicationActivities: nil)
        share.popoverPresentationController?.sourceView = rootViewController!.presentedViewController!.view
        share.popoverPresentationController?.sourceRect = .zero
        share.popoverPresentationController?.permittedArrowDirections = .any
        rootViewController!.presentedViewController!.present(share, animated: true)
    }
    
    @objc private func browser() {
        if #available(iOS 11.0, *) {
            let browse = UIDocumentBrowserViewController()
            browse.browserUserInterfaceStyle = .dark
            browse.delegate = self
            browse.additionalLeadingNavigationBarButtonItems = [.init(barButtonSystemItem: .stop, target: self,
                                                                                action: #selector(dismiss))]
            rootViewController!.present(browse, animated: true)
        }
    }
    
    @objc private func dismiss() { rootViewController!.dismiss(animated: true) }
}
