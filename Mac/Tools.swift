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
        commit.off = NSImage(named: "addOff")
        commit.on = NSImage(named: "addOn")
        commit.width.constant = 65
        commit.height.constant = 65
        addSubview(commit)
        
        let log = Button.Image(self, action: #selector(self.log))
        log.off = NSImage(named: "logOff")
        log.on = NSImage(named: "logOn")
        log.width.constant = 50
        log.height.constant = 50
        addSubview(log)
        
        let credentials = Button.Image(NSApp, action: #selector(App.preferences))
        credentials.off = NSImage(named: "credentialsOff")
        credentials.on = NSImage(named: "credentialsOn")
        credentials.width.constant = 50
        credentials.height.constant = 50
        addSubview(credentials)
        
        let reset = Button.Image(self, action: #selector(self.reset))
        reset.off = NSImage(named: "resetOff")
        reset.on = NSImage(named: "resetOn")
        reset.width.constant = 50
        reset.height.constant = 50
        addSubview(reset)
        
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        commit.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        commit.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        log.rightAnchor.constraint(equalTo: commit.leftAnchor, constant: -20).isActive = true
        log.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        credentials.rightAnchor.constraint(equalTo: log.leftAnchor, constant: -20).isActive = true
        credentials.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        reset.leftAnchor.constraint(equalTo: commit.rightAnchor, constant: 20).isActive = true
        reset.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    @objc func log() { Log() }
    @objc func reset() { Reset() }
    @objc func commit() {
        if Hub.session.name.isEmpty || Hub.session.email.isEmpty {
            (NSApp as! App).preferences()
        } else {
            Commit()
        }
    }
}
