import AppKit

class Tools: NSView {
    private(set) weak var height: NSLayoutConstraint!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = NSColor.black.cgColor
        
        let commit = Button(target: self, action: #selector(self.commit))
        commit.image = NSImage(named: "commit")
        commit.imageScaling = .scaleNone
        commit.width.constant = 45
        commit.height.constant = 45
        addSubview(commit)
        
        height = heightAnchor.constraint(equalToConstant: 0)
        height.isActive = true
        
        commit.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -10).isActive = true
        commit.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc func commit() {
//        App.shared.repository?.user.name = "john"
//        App.shared.repository?.user.email = "john@mail.com"
        App.shared.repository?.commit(
            (App.shared.list.documentView!.subviews as! [Item]).filter({ $0.stage.state == .on }).map { $0.url },
            message:"Git commit", error: {
                App.shared.alert.show($0.localizedDescription)
        })
    }
}
