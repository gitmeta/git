import AppKit

class Tools: NSView {
    private(set) weak var height: NSLayoutConstraint!
    private weak var text: NSTextView!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = NSColor.black.cgColor
        
        let text = Text()
        self.text = text
        
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.drawsBackground = false
        scroll.documentView = text
        scroll.hasVerticalScroller = true
        scroll.verticalScroller!.controlSize = .mini
        scroll.horizontalScrollElasticity = .none
        scroll.verticalScrollElasticity = .allowed
        addSubview(scroll)
        
        let commit = Button(target: self, action: #selector(self.commit))
        commit.image = NSImage(named: "commit")
        commit.imageScaling = .scaleNone
        commit.width.constant = 65
        commit.height.constant = 65
        addSubview(commit)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        text.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        text.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor).isActive = true
        
        height = heightAnchor.constraint(equalToConstant: 0)
        height.isActive = true
        
        commit.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -10).isActive = true
        commit.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc func commit() {
        guard let user = App.shared.user
        else {
            Credentials()
            return
        }
        App.shared.repository?.user = user
        App.shared.repository?.commit(
            (App.shared.list.documentView!.subviews as! [Item]).filter({ $0.stage.state == .on }).map { $0.url },
            message:"Git commit", error: {
                App.shared.alert.show($0.localizedDescription)
        })
    }
}
