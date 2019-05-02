import AppKit

class Tools: NSView {
    weak var top: NSLayoutConstraint! { didSet { top.isActive = true } }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        isHidden = true
        layer!.backgroundColor = NSColor.black.cgColor
        
        let commit = Button.Image(self, action: #selector(self.commit))
        commit.off = NSImage(named: "addOff")
        commit.on = NSImage(named: "addOn")
        commit.width.constant = 65
        commit.height.constant = 65
        addSubview(commit)
        
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        commit.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        commit.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc func commit() { Commit() }
    
    /*
    @objc func commit() {
        guard !App.session.email.isEmpty, !App.session.name.isEmpty
        else {
            Credentials()
            return
        }
        let message = text.string
        do {
            let user = try User(App.session.name, email: App.session.email)
            App.repository?.commit(
                (App.window.list.documentView!.subviews as! [Item]).filter({ $0.stage.checked }).map { $0.url },
                user: user, message: message, error: { App.window.alert.error($0.localizedDescription) }) { [weak self] in
                    App.window.refresh()
                    self?.text.string = ""
                    App.window.alert.commit(message)
            }
        } catch {
            App.window.alert.error(error.localizedDescription)
        }
    }*/
}
