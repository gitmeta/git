import AppKit

class Tools: NSView {
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
        
        heightAnchor.constraint(equalToConstant: 140).isActive = true
        
        commit.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        commit.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc private func commit() {
        
    }
}
