import Git
import AppKit

final class History: Window {
    private final class Item: NSView {
        override var isOpaque: Bool { return true }
        override var wantsDefaultClipping: Bool { return false }
        
        required init?(coder: NSCoder) { return nil }
        init(_ index: Int, commit: Commit, date: String) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let label = Label()
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.attributedStringValue = {
                $0.append(NSAttributedString(string: "\(index) ", attributes: [.font: NSFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: NSColor.halo]))
                $0.append(NSAttributedString(string: commit.author.name + " ", attributes: [.font: NSFont.light(18), .foregroundColor: NSColor.halo]))
                $0.append(NSAttributedString(string: date + "\n", attributes: [.font: NSFont.systemFont(ofSize: 12, weight: .light), .foregroundColor: NSColor.halo]))
                $0.append(NSAttributedString(string: commit.message, attributes: [.font: NSFont.light(14), .foregroundColor: NSColor.white]))
                return $0
            } (NSMutableAttributedString())
            addSubview(label)
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.2).cgColor
            addSubview(border)
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
            label.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -10).isActive = true
            
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
    }
    
    private weak var scroll: NSScrollView!
    private weak var loading: NSImageView!
    private weak var branch: Label!
    private weak var bottom: NSLayoutConstraint? { didSet { oldValue?.isActive = false; bottom?.isActive = true } }
    private let formatter = DateFormatter()
    
    init() {
        super.init(400, 500, style: .resizable)
        name.stringValue = .key("History.title")
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        let loading = NSImageView()
        loading.image = NSImage(named: "loading")
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.imageScaling = .scaleNone
        contentView!.addSubview(loading)
        self.loading = loading
        
        let branch = Label()
        branch.font = .systemFont(ofSize: 14, weight: .bold)
        branch.textColor = .halo
        contentView!.addSubview(branch)
        self.branch = branch
        
        let scroll = Scroll()
        scroll.flip()
        contentView!.addSubview(scroll)
        self.scroll = scroll
        
        loading.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        loading.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        loading.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        loading.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        branch.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 18).isActive = true
        branch.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -16).isActive = true
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        
        refresh()
    }
    
    func refresh() {
        loading.isHidden = false
        branch.stringValue = ""
        scroll.documentView!.subviews.forEach { $0.removeFromSuperview() }
        
        app.repository?.log { [weak self] items in
            guard let scroll = self?.scroll, let formatter = self?.formatter else { return }
            var top = scroll.documentView!.topAnchor
            items.enumerated().forEach {
                let item = Item(items.count - $0.0, commit: $0.1, date: formatter.string(from: $0.1.author.date))
                scroll.documentView!.addSubview(item)
                
                item.topAnchor.constraint(equalTo: top).isActive = true
                item.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
                item.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
                top = item.bottomAnchor
            }
            self?.bottom = scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: top)
            
            app.repository?.branch { [weak self] in
                self?.branch.stringValue = $0
                self?.loading.isHidden = true
            }
        }
    }
}
