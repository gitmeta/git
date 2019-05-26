import Git
import AppKit

class Log: NSWindow {
    private class Item: NSView {
        private weak var label: Label!
        
        init(_ index: Int, commit: Git.Commit) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let number = Label(String(index))
            number.alignment = .center
            number.font = .systemFont(ofSize: 20, weight: .bold)
            number.textColor = .halo
            addSubview(number)
            
            let author = Label(commit.author.name)
            author.textColor = .halo
            author.font = .systemFont(ofSize: 16, weight: .bold)
            addSubview(author)
            
            let container = NSView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.wantsLayer = true
            container.layer!.backgroundColor = NSColor.halo.cgColor
            container.layer!.cornerRadius = 4
            addSubview(container)
            
            let date = Label({
                $0.timeStyle = .short
                $0.dateStyle = Calendar.current.dateComponents([.hour], from: $1, to: Date()).hour! > 12 ? .medium : .none
                return $0.string(from: $1)
            } (DateFormatter(), commit.author.date))
            date.textColor = .black
            date.font = .systemFont(ofSize: 12, weight: .regular)
            date.alignment = .right
            addSubview(date)
            
            let label = Label(commit.message)
            label.textColor = .white
            label.font = .systemFont(ofSize: 14, weight: .light)
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.isSelectable = true
            addSubview(label)
            self.label = label
            
            number.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            number.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            
            author.bottomAnchor.constraint(equalTo: number.bottomAnchor, constant: -2).isActive = true
            author.leftAnchor.constraint(equalTo: number.rightAnchor, constant: 5).isActive = true
            
            container.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
            container.heightAnchor.constraint(equalToConstant: 24).isActive = true
            container.centerYAnchor.constraint(equalTo: number.centerYAnchor).isActive = true
            container.leftAnchor.constraint(equalTo: date.leftAnchor, constant: -8).isActive = true
            
            date.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
            date.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -8).isActive = true
            
            label.topAnchor.constraint(equalTo: number.bottomAnchor, constant: 12).isActive = true
            label.leftAnchor.constraint(equalTo: number.leftAnchor, constant: 2).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -12).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private weak var scroll: NSScrollView!
    
    init() {
        super.init(contentRect: NSRect(x: App.home.frame.minX + 40, y: App.home.frame.minY - 40, width: 600, height: 600),
                   styleMask: [.closable, .fullSizeContentView, .miniaturizable, .resizable, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        minSize = NSSize(width: 400, height: 400)
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let cancel = Button.Image(self, action: #selector(close))
        cancel.image.image = NSImage(named: "cancel")
//        cancel.width.constant = 24
//        cancel.height.constant = 24
        contentView!.addSubview(cancel)
        
        let title = Label(.local("Log.title"))
        title.textColor = .halo
        title.font = .systemFont(ofSize: 14, weight: .bold)
        contentView!.addSubview(title)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = NSColor.black.cgColor
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
        
        cancel.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        cancel.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 8).isActive = true
        
        title.centerYAnchor.constraint(equalTo: cancel.centerYAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: cancel.leftAnchor, constant: -10).isActive = true
        
        border.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        
        App.repository?.log { [weak scroll] items in
            guard let scroll = scroll else { return }
            var top = scroll.documentView!.topAnchor
            items.enumerated().forEach {
                let item = Item(items.count - $0.0, commit: $0.1)
                scroll.documentView!.addSubview(item)
                
                item.topAnchor.constraint(equalTo: top, constant: 10).isActive = true
                item.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
                item.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
                top = item.bottomAnchor
            }
            scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: top, constant: 20).isActive = true
        }
    }
    
    override func close() {
        scroll.removeFromSuperview()
        super.close()
    }
}
