import Git
import AppKit

class Tools: NSView {
    weak var top: NSLayoutConstraint! { didSet { top.isActive = true } }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = NSColor.black.cgColor
        
        let commit = Button.Image(self, action: #selector(self.commit))
        commit.image.image = NSImage(named: "add")
        commit.width.constant = 32
        commit.height.constant = 32
        addSubview(commit)
        
        let log = Button.Image(self, action: #selector(self.log))
        log.image.image = NSImage(named: "log")
        log.width.constant = 27
        log.height.constant = 27
        addSubview(log)
        
        let credentials = Button.Image(App.global, action: #selector(App.preferences))
        credentials.image.image = NSImage(named: "credentials")
        credentials.width.constant = 27
        credentials.height.constant = 27
        addSubview(credentials)
        
        let reset = Button.Image(self, action: #selector(self.reset))
        reset.image.image = NSImage(named: "reset")
        reset.width.constant = 27
        reset.height.constant = 27
        addSubview(reset)
        
        heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        commit.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        commit.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        log.rightAnchor.constraint(equalTo: commit.leftAnchor, constant: -30).isActive = true
        log.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        credentials.rightAnchor.constraint(equalTo: log.leftAnchor, constant: -30).isActive = true
        credentials.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        reset.leftAnchor.constraint(equalTo: commit.rightAnchor, constant: 30).isActive = true
        reset.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc func log() {
        Log().makeKeyAndOrderFront(nil)
    }
    
    @objc func reset() { Reset() }
    @objc func commit() {
        if Hub.session.name.isEmpty || Hub.session.email.isEmpty {
            App.global.preferences()
        } else {
            Commit()
        }
    }
}
