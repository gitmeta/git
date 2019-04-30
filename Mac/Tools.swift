import Git
import AppKit

class Tools: NSView {
    weak var bottom: NSLayoutConstraint! { didSet { bottom.isActive = true } }
    private weak var text: NSTextView!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
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
        addSubview(scroll)
        
        let commit = Button(target: self, action: #selector(self.commit))
        commit.image = NSImage(named: "commitOff")
        commit.alternateImage = NSImage(named: "commitOn")
        commit.imageScaling = .scaleNone
        commit.width.constant = 65
        commit.height.constant = 65
        addSubview(commit)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        text.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        text.heightAnchor.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        
        commit.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -10).isActive = true
        commit.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
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
                (App.window.list.documentView!.subviews as! [Item]).filter({ $0.stage.state == .on }).map { $0.url },
                user: user, message: message, error: { App.window.alert.error($0.localizedDescription) }) {
                    App.window.alert.commit(message)
            }
        } catch {
            App.window.alert.error(error.localizedDescription)
        }
    }
}
