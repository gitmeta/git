import Git
import AppKit

class List: NSScrollView {
    class Item: NSView {
        let url: URL
        private(set) weak var stage: Button.Check!
        private weak var previous: Item?
        private weak var next: Item?
        private weak var badge: NSView!
        private weak var label: Label!
        private weak var hashtag: Label!
        private weak var top: NSLayoutConstraint? { didSet { oldValue?.isActive = false; top?.isActive = true } }
        
        fileprivate init(_ url: URL) {
            self.url = url
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let label = Label()
            label.attributedStringValue = {
                let path = url.deletingLastPathComponent().path.dropFirst(Hub.session.url.path.count + 1)
                if !path.isEmpty {
                    $0.append(NSAttributedString(string:
                        "\(path) ", attributes:
                        [.font: NSFont.light(14), .foregroundColor: NSColor.halo.withAlphaComponent(0.7)]))
                }
                $0.append(NSAttributedString(string: url.lastPathComponent, attributes:
                    [.font: NSFont.bold(14), .foregroundColor: NSColor.halo]))
                return $0
            } (NSMutableAttributedString())
            label.maximumNumberOfLines = 1
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            self.label = label
            
            let badge = NSView()
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.wantsLayer = true
            badge.layer!.cornerRadius = 4
            addSubview(badge)
            self.badge = badge
            
            let hashtag = Label()
            hashtag.textColor = .black
            hashtag.font = .systemFont(ofSize: 12, weight: .light)
            addSubview(hashtag)
            self.hashtag = hashtag
            
            let stage = Button.Check(self, action: #selector(change))
            stage.off = NSImage(named: "checkOff")
            stage.on = NSImage(named: "checkOn")
            stage.checked = true
            stage.height.constant = 32
            stage.width.constant = 32
            addSubview(stage)
            self.stage = stage
            
            heightAnchor.constraint(equalToConstant: 32).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: badge.leftAnchor, constant: -20).isActive = true
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
            
            badge.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            badge.rightAnchor.constraint(equalTo: stage.leftAnchor, constant: -4).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 24).isActive = true
            badge.leftAnchor.constraint(equalTo: hashtag.leftAnchor, constant: -9).isActive = true
            
            hashtag.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
            hashtag.rightAnchor.constraint(equalTo: badge.rightAnchor, constant: -9).isActive = true
            
            stage.rightAnchor.constraint(equalTo: rightAnchor, constant: -4).isActive = true
            stage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
        
        fileprivate func status(_ current: Status) {
            switch current {
            case .deleted:
                badge.layer!.backgroundColor = NSColor.deleted.cgColor
                hashtag.stringValue = .local("Item.deleted")
            case .added:
                badge.layer!.backgroundColor = NSColor.added.cgColor
                hashtag.stringValue = .local("Item.added")
            case .modified:
                badge.layer!.backgroundColor = NSColor.modified.cgColor
                hashtag.stringValue = .local("Item.modified")
            case .untracked:
                badge.layer!.backgroundColor = NSColor.untracked.cgColor
                hashtag.stringValue = .local("Item.untracked")
            }
        }
        
        fileprivate func disconnect() {
            next?.top = next?.topAnchor.constraint(equalTo: previous?.bottomAnchor ?? superview!.topAnchor)
            previous?.next = next
            next?.previous = previous
        }
        
        fileprivate func connect(_ previous: Item?) {
            top = topAnchor.constraint(equalTo: previous?.bottomAnchor ?? superview!.topAnchor)
            previous?.next?.top = previous?.next?.topAnchor.constraint(equalTo: bottomAnchor)
            next = previous?.next
            next?.previous = self
            previous?.next = self
            self.previous = previous
        }
        
        @objc private func change() { alphaValue = stage.checked ? 1 : 0.4 }
    }
    
    private weak var bottom: NSLayoutConstraint? { didSet { oldValue?.isActive = false; bottom?.isActive = true } }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        alphaValue = 0
        drawsBackground = false
        hasVerticalScroller = true
        verticalScroller!.controlSize = .mini
        verticalScrollElasticity = .allowed
        documentView = Flipped()
        documentView!.translatesAutoresizingMaskIntoConstraints = false
        documentView!.topAnchor.constraint(equalTo: topAnchor).isActive = true
        documentView!.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        documentView!.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func update(_ items: [(URL, Status)]) {
        var before = documentView!.subviews as! [Item]
        var last: Item?
        items.forEach { item in
            let new: Item
            if let index = before.firstIndex(where: { $0.url == item.0 }) {
                new = before.remove(at: index)
                new.disconnect()
            } else {
                new = Item(item.0)
                documentView!.addSubview(new)
        
                new.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                new.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            }
            new.status(item.1)
            new.connect(last)
            last = new
        }
        bottom = documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: last?.bottomAnchor ?? bottomAnchor, constant: 20)
        before.forEach({ $0.removeFromSuperview() })
    }
}
