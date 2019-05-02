import Git
import AppKit

class Tools: NSView {
    weak var top: NSLayoutConstraint! { didSet { top.isActive = true } }
    private weak var text: NSTextView!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = NSColor.black.cgColor
        
        let text = Text()
        self.text = text
        
        let scroll = NSScrollView()
        scroll.wantsLayer = true
        scroll.layer!.cornerRadius = 8
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = .black
        scroll.documentView = text
        scroll.hasVerticalScroller = true
        scroll.verticalScroller!.controlSize = .mini
        scroll.horizontalScrollElasticity = .none
        scroll.verticalScrollElasticity = .allowed
        scroll.isHidden = true
        addSubview(scroll)
        
        let commit = Button.Image(self, action: #selector(self.commit))
        commit.off = NSImage(named: "commitOff")
        commit.on = NSImage(named: "commitOn")
        commit.width.constant = 65
        commit.height.constant = 65
        addSubview(commit)
        
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        text.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        text.heightAnchor.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        
        commit.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        commit.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
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
    }
}
