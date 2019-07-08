import Git
import AppKit

final class Timeline: Window {
    private final class Node: Button {
        let index: Int
        var selected = false { didSet { hover() } }
        private weak var circle: NSView!
        private weak var width: NSLayoutConstraint!
        private weak var height: NSLayoutConstraint!
        
        required init?(coder: NSCoder) { return nil }
        init(_ index: Int, target: Timeline, action: Selector) {
            self.index = index
            super.init(target, action: action)
            
            let circle = NSView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.wantsLayer = true
            circle.layer!.borderWidth = 1
            addSubview(circle)
            self.circle = circle
            
            heightAnchor.constraint(equalToConstant: 30).isActive = true
            widthAnchor.constraint(equalToConstant: 30).isActive = true
            
            circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            
            height = circle.heightAnchor.constraint(equalToConstant: 0)
            width = circle.widthAnchor.constraint(equalToConstant: 0)
            height.isActive = true
            width.isActive = true
            hover()
        }
        
        private func hover() {
            if selected {
                width.constant = 24
                height.constant = 24
                circle.layer!.cornerRadius = 12
                circle.layer!.backgroundColor = NSColor.halo.cgColor
                circle.layer!.borderColor = .clear
            } else {
                width.constant = 10
                height.constant = 10
                circle.layer!.cornerRadius = 5
                circle.layer!.backgroundColor = .black
                circle.layer!.borderColor = NSColor.halo.cgColor
            }
        }
    }
    
    let url: URL
    private weak var scroll: Scroll!
    private weak var date: Label!
    private weak var base: NSView!
    private weak var y: NSLayoutConstraint? { willSet { y?.isActive = false } didSet { y!.isActive = true } }
    private var items = [(String, Data)]()
    
    init(_ url: URL) {
        self.url = url
        super.init(500, 500, style: .resizable)
        minSize = CGSize(width: 200, height: 200)
        name.attributedStringValue = {
            $0.append(NSAttributedString(string: .key("Timeline.title") + " ", attributes: [.font: NSFont.systemFont(ofSize: 12, weight: .bold)]))
            $0.append(NSAttributedString(string: url.path, attributes: [.font: NSFont.systemFont(ofSize: 12, weight: .light)]))
            return $0
        } (NSMutableAttributedString())
        
        let loading = NSImageView()
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.image = NSImage(named: "loading")
        loading.imageScaling = .scaleNone
        contentView!.addSubview(loading)
        
        let scroll = Scroll()
        scroll.flip()
        scroll.hasVerticalScroller = false
        contentView!.addSubview(scroll)
        self.scroll = scroll
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.backgroundColor = NSColor.halo.cgColor
        base.layer!.cornerRadius = 12
        base.isHidden = true
        scroll.documentView!.addSubview(base)
        self.base = base
        
        let date = Label()
        date.font = .systemFont(ofSize: 12, weight: .medium)
        date.textColor = .black
        base.addSubview(date)
        self.date = date
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        base.heightAnchor.constraint(equalToConstant: 24).isActive = true
        base.centerYAnchor.constraint(equalTo: date.centerYAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 44).isActive = true
        base.leftAnchor.constraint(equalTo: date.leftAnchor, constant: -12).isActive = true
        base.rightAnchor.constraint(equalTo: date.rightAnchor, constant: 12).isActive = true
        
        loading.widthAnchor.constraint(equalToConstant: 100).isActive = true
        loading.heightAnchor.constraint(equalToConstant: 40).isActive = true
        loading.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        
        app.repository?.timeline(url, error: { app.alert(.key("Alert.error"), message: $0.localizedDescription) }) { [weak self, weak loading, weak base] in
            let format = DateFormatter()
            format.timeStyle = .short
            format.dateStyle = .medium
            self?.items = $0.map { (format.string(from: $0.0), $0.1) }
            if let last = self?.items.popLast() {
                self?.items.append((.key("Timeline.now"), last.1))
            }
            self?.render()
            loading?.removeFromSuperview()
            base?.isHidden = false
        }
    }
    
    private func render() {
        let track = NSView()
        track.translatesAutoresizingMaskIntoConstraints = false
        track.wantsLayer = true
        track.layer!.backgroundColor = NSColor.halo.cgColor
        scroll.documentView!.addSubview(track)
        
        var last: Node?
        items.enumerated().forEach {
            let node = Node($0.0, target: self, action: #selector(choose(_:)))
            scroll.documentView!.addSubview(node)
            
            node.centerXAnchor.constraint(equalTo: scroll.leftAnchor, constant: 25).isActive = true
            
            if $0.0 == 0 {
                node.centerYAnchor.constraint(equalTo: track.topAnchor).isActive = true
            } else {
                node.centerYAnchor.constraint(equalTo: last!.centerYAnchor, constant: 60).isActive = true
            }
            
            last = node
        }
        
        track.widthAnchor.constraint(equalToConstant: 2).isActive = true
        track.centerXAnchor.constraint(equalTo: scroll.leftAnchor, constant: 25).isActive = true
        track.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor, constant: 50).isActive = true
        track.bottomAnchor.constraint(equalTo: last!.centerYAnchor).isActive = true
        
        scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: track.bottomAnchor, constant: 50).isActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in self?.choose(last!) }
    }
    
    private func content(_ index: Int) {
        date.stringValue = items[index].0
    }
    
    @objc private func choose(_ node: Node) {
        scroll.documentView!.subviews.compactMap({ $0 as? Node }).forEach { $0.selected = $0 === node }
        content(node.index)
        y = base.centerYAnchor.constraint(equalTo: node.centerYAnchor)
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            base.alphaValue = 1
            scroll.documentView!.layoutSubtreeIfNeeded()
            scroll.contentView.scrollToVisible(CGRect(x: 0, y: node.frame.midY - scroll.bounds.midY, width: 1, height: scroll.bounds.height))
        }) { }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            NSAnimationContext.runAnimationGroup({
                $0.duration = 5
                $0.allowsImplicitAnimation = true
                self?.base.alphaValue = 0
            }) { }
        }
    }
}
