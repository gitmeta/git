import AppKit

class Tools: NSView {
    private(set) weak var height: NSLayoutConstraint!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = NSColor.shade.cgColor
        
        let commit = Button(target: self, action: #selector(self.commit))
        commit.image = NSImage(named: "commit")
        commit.imageScaling = .scaleNone
        commit.width.constant = 52
        commit.height.constant = 30
        addSubview(commit)
        
        height = heightAnchor.constraint(equalToConstant: 0)
        height.isActive = true
        
        commit.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        commit.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc private func commit() {
//        App.shared.list.items.filter({ $0.stage.state == .on }).forEach {
//            print($0)
//        }
    }
}
