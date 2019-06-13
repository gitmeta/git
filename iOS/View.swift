import UIKit
import UserNotifications

class View: UIViewController, UIDocumentBrowserViewControllerDelegate, UNUserNotificationCenterDelegate {
    /*
    let alert = Alert()
    private(set) weak var branch: Bar!
    private(set) weak var list: List!
    private weak var tools: Tools!
    private weak var display: Display!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .shade
        
        let display = Display()
        view.addSubview(display)
        self.display = display
        
        let location = Bar.Location()
        location.addTarget(self, action: #selector(browser), for: .touchUpInside)
        view.addSubview(location)
        
        let branch = Bar.Branch()
        view.addSubview(branch)
        self.branch = branch
        
        let help = UIButton()
        help.addTarget(self, action: #selector(self.help), for: .touchUpInside)
        help.translatesAutoresizingMaskIntoConstraints = false
        help.setImage(#imageLiteral(resourceName: "helpOff.pdf"), for: .normal)
        help.setImage(#imageLiteral(resourceName: "helpOn.pdf"), for: .highlighted)
        help.imageView!.clipsToBounds = true
        help.imageView!.contentMode = .center
        view.addSubview(help)
        
        let list = List()
        view.addSubview(list)
        self.list = list
        
        let tools = Tools()
        view.addSubview(tools)
        self.tools = tools
        
        display.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        display.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        display.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        display.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        location.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        branch.topAnchor.constraint(equalTo: location.topAnchor).isActive = true
        branch.leftAnchor.constraint(equalTo: location.rightAnchor, constant: -16).isActive = true
        branch.rightAnchor.constraint(equalTo: help.leftAnchor).isActive = true
        
        help.topAnchor.constraint(equalTo: location.topAnchor).isActive = true
        help.bottomAnchor.constraint(equalTo: location.bottomAnchor).isActive = true
        help.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        help.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        list.topAnchor.constraint(equalTo: location.bottomAnchor, constant: 2).isActive = true
        list.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        list.bottomAnchor.constraint(greaterThanOrEqualTo: tools.topAnchor, constant: -2).isActive = true
        
        tools.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tools.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tools.top = tools.topAnchor.constraint(equalTo: view.bottomAnchor)
        
        if #available(iOS 11.0, *) {
            location.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        } else {
            location.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().getNotificationSettings {
                if $0.authorizationStatus != .authorized {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                }
            }
        }
        
        App.shared.load()
    }
    
    @available(iOS 10.0, *) func userNotificationCenter(_: UNUserNotificationCenter, willPresent:
        UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 10) {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [willPresent.request.identifier])
        }
    }
    
    @available(iOS 11.0, *) func documentBrowser(_: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler:
        @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        App.shared.rootViewController!.presentedViewController!.present(Create { url in
            App.shared.rootViewController!.presentedViewController?.dismiss(animated: true) {
                didRequestDocumentCreationWithHandler(url, url == nil ? .none : .move)
            }
        }, animated: true)
    }
    
    @available(iOS 11.0, *) func documentBrowser(_: UIDocumentBrowserViewController, didPickDocumentsAt: [URL]) {
        let share = UIActivityViewController(activityItems: didPickDocumentsAt, applicationActivities: nil)
        share.popoverPresentationController?.sourceView = App.shared.rootViewController!.presentedViewController!.view
        share.popoverPresentationController?.sourceRect = .zero
        share.popoverPresentationController?.permittedArrowDirections = .any
        App.shared.rootViewController!.presentedViewController!.present(share, animated: true)
    }
    
    func repository() {
        tools.top.constant = -tools.frame.height
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
            self.list.alpha = 1
            self.display.repository()
        }
    }
    
    func notRepository() {
        tools.top.constant = 0
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
            self.list.alpha = 0
            self.display.notRepository()
        }
    }
    
    func upToDate() {
        tools.top.constant = -tools.frame.height
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
            self.list.alpha = 0
            self.display.upToDate()
        }
    }
    
    @objc func refresh() {
        App.repository?.refresh()
        tools.top.constant = 0
        list.subviews.forEach { $0.removeFromSuperview() }
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
            self.list.alpha = 0
            self.display.loading()
        }
    }
    
    @objc func credentials() { Credentials() }
    @objc private func back() { App.view.dismiss(animated: true) }
    @objc private func help() { Onboard() }
    
    @objc private func browser() {
        if #available(iOS 11.0, *) {
            let browse = UIDocumentBrowserViewController()
            browse.browserUserInterfaceStyle = .dark
            browse.delegate = self
            browse.additionalLeadingNavigationBarButtonItems = [.init(barButtonSystemItem: .stop, target: self,
                                                                      action: #selector(back))]
            App.view.present(browse, animated: true)
        }
    }
    */
}
