import Git
import AppKit

final class History: NSWindow {
    private final class Item: NSView {
        override var isOpaque: Bool { return true }
        override var wantsDefaultClipping: Bool { return false }
        
        init(_ index: Int, commit: Commit) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let number = Label(String(index))
            number.alignment = .center
            number.font = .systemFont(ofSize: 16, weight: .bold)
            number.textColor = .halo
            addSubview(number)
            
            let author = Label(commit.author.name)
            author.textColor = .halo
            author.font = .systemFont(ofSize: 16, weight: .medium)
            addSubview(author)
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = .black
            addSubview(border)
            
            let date = Label({
                $0.timeStyle = .short
                $0.dateStyle = Calendar.current.dateComponents([.hour], from: $1, to: Date()).hour! > 12 ? .medium : .none
                return $0.string(from: $1)
                } (DateFormatter(), commit.author.date))
            date.textColor = .halo
            date.font = .systemFont(ofSize: 12, weight: .light)
            addSubview(date)
            
            let label = Label(commit.message)
            label.textColor = .white
            label.font = .light(14)
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.isSelectable = true
            addSubview(label)
            
            number.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            number.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
            
            author.bottomAnchor.constraint(equalTo: number.bottomAnchor).isActive = true
            author.leftAnchor.constraint(equalTo: number.rightAnchor, constant: 2).isActive = true
            
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -2).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            date.leftAnchor.constraint(equalTo: number.leftAnchor, constant: 3).isActive = true
            date.topAnchor.constraint(equalTo: number.bottomAnchor, constant: 5).isActive = true
            
            label.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 16).isActive = true
            label.leftAnchor.constraint(equalTo: number.leftAnchor, constant: 3).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
            label.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -20).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private weak var scroll: NSScrollView!
    private weak var loading: NSImageView!
    private weak var branch: Label!
    private weak var bottom: NSLayoutConstraint? { didSet { oldValue?.isActive = false; bottom?.isActive = true } }
    
    init() {
        super.init(contentRect: NSRect(
            x: app.home.frame.minX + 50, y: app.home.frame.maxY - 550, width: 400, height: 500),
                   styleMask: [.closable, .fullSizeContentView, .miniaturizable, .resizable, .titled, .unifiedTitleAndToolbar],
                   backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .shade
        collectionBehavior = .fullScreenNone
        minSize = NSSize(width: 100, height: 100)
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
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
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        contentView!.addSubview(border)
        
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.verticalScroller!.controlSize = .mini
        scroll.horizontalScrollElasticity = .none
        scroll.verticalScrollElasticity = .allowed
        scroll.documentView = Flipped()
        scroll.documentView!.translatesAutoresizingMaskIntoConstraints = false
        scroll.documentView!.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        scroll.documentView!.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        scroll.documentView!.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        contentView!.addSubview(scroll)
        self.scroll = scroll
        
        loading.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        loading.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        loading.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        loading.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        branch.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 18).isActive = true
        branch.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -20).isActive = true
        
        border.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 39).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        
        refresh()
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 13:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                close()
            } else {
                super.keyDown(with: with)
            }
        case 53: close()
        default: super.keyDown(with: with)
        }
    }
    
    func refresh() {
        loading.isHidden = false
        branch.stringValue = ""
        scroll.documentView!.subviews.forEach { $0.removeFromSuperview() }
        
        app.repository?.log { [weak self] items in
            guard let scroll = self?.scroll else { return }
            var top = scroll.documentView!.topAnchor
            items.enumerated().forEach {
                let item = Item(items.count - $0.0, commit: $0.1)
                scroll.documentView!.addSubview(item)
                
                item.topAnchor.constraint(equalTo: top, constant: 10).isActive = true
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
