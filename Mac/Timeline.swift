import Git
import AppKit

final class Timeline: Window {
    private final class Node: Button {
        let index: Int
        
        required init?(coder: NSCoder) { return nil }
        init(_ index: Int, target: Timeline, action: Selector) {
            self.index = index
            super.init(target, action: action)
            wantsLayer = true
            layer!.backgroundColor = NSColor.halo.cgColor
            
            widthAnchor.constraint(equalToConstant: 20).isActive = true
            heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
    }
    
    let url: URL
    private weak var scroll: Scroll!
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
        contentView!.addSubview(scroll)
        self.scroll = scroll
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = self.border.layer!.backgroundColor
        contentView!.addSubview(border)
        
        scroll.topAnchor.constraint(equalTo: self.border.bottomAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        scroll.widthAnchor.constraint(equalToConstant: 58).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        
        border.topAnchor.constraint(equalTo: self.border.bottomAnchor).isActive = true
        border.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        border.widthAnchor.constraint(equalToConstant: 1).isActive = true
        border.leftAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        
        loading.widthAnchor.constraint(equalToConstant: 100).isActive = true
        loading.heightAnchor.constraint(equalToConstant: 40).isActive = true
        loading.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        
        app.repository?.timeline(url, error: { app.alert(.key("Alert.error"), message: $0.localizedDescription) }) { [weak self, weak loading] in
            let format = DateFormatter()
            format.timeStyle = .short
            format.dateStyle = .medium
            self?.items = $0.map { (format.string(from: $0.0), $0.1) }
            if let last = self?.items.popLast() {
                self?.items.append((.key("Timeline.now"), last.1))
            }
            self?.render()
            loading?.isHidden = true
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
            
            node.centerXAnchor.constraint(equalTo: scroll.centerXAnchor).isActive = true
            
            if $0.0 == 0 {
                node.centerYAnchor.constraint(equalTo: track.topAnchor).isActive = true
            } else {
                node.centerYAnchor.constraint(equalTo: last!.bottomAnchor, constant: 50).isActive = true
            }
            
            last = node
        }
        
        track.widthAnchor.constraint(equalToConstant: 2).isActive = true
        track.centerXAnchor.constraint(equalTo: scroll.centerXAnchor).isActive = true
        track.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor, constant: 50).isActive = true
        track.bottomAnchor.constraint(equalTo: last!.centerYAnchor).isActive = true
        
        scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: track.bottomAnchor, constant: 50).isActive = true
        
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in self?.choose(choose, stop: stop) }
    }
    
    @objc private func choose(_ node: Node) {
        
    }
}
