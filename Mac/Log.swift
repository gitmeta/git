import Git
import AppKit

class Log: Sheet {
    private class Item: NSView {
        private weak var label: Label!
        
        init(_ index: Int, commit: Git.Commit) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let circle = NSView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.wantsLayer = true
            circle.layer!.backgroundColor = NSColor.halo.cgColor
            circle.layer!.cornerRadius = 17
            addSubview(circle)
            
            let number = Label(String(index))
            number.alignment = .center
            number.font = .systemFont(ofSize: 12, weight: .medium)
            number.textColor = .black
            addSubview(number)
            
            let author = Label(commit.author.name)
            author.textColor = NSColor(white: 1, alpha: 0.5)
            author.font = .systemFont(ofSize: 16, weight: .medium)
            addSubview(author)
            
            let date = Label({
                $0.timeStyle = .short
                $0.dateStyle = Calendar.current.dateComponents([.hour], from: $1, to: Date()).hour! > 12 ? .long : .none
                return $0.string(from: $1)
            } (DateFormatter(), commit.author.date))
            date.textColor = NSColor(white: 1, alpha: 0.5)
            date.font = .systemFont(ofSize: 12, weight: .light)
            addSubview(date)
            
            let label = Label(commit.message)
            label.textColor = .white
            label.font = .systemFont(ofSize: 16, weight: .light)
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            self.label = label
            
            circle.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            circle.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
            circle.widthAnchor.constraint(equalToConstant: 34).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 34).isActive = true
            
            number.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
            number.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
            
            author.bottomAnchor.constraint(equalTo: date.topAnchor).isActive = true
            author.leftAnchor.constraint(equalTo: date.leftAnchor).isActive = true
            
            date.bottomAnchor.constraint(equalTo: circle.bottomAnchor).isActive = true
            date.leftAnchor.constraint(equalTo: circle.rightAnchor, constant: 7).isActive = true
            
            label.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 30).isActive = true
            label.leftAnchor.constraint(equalTo: circle.leftAnchor, constant: 6).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    @discardableResult override init() {
        super.init()
        let cancel = Button.Image(self, action: #selector(close))
        cancel.off = NSImage(named: "cancelOff")
        cancel.on = NSImage(named: "cancelOn")
        cancel.width.constant = 40
        cancel.height.constant = 40
        addSubview(cancel)
        
        let title = Label(.local("Log.title"))
        title.textColor = .halo
        title.font = .systemFont(ofSize: 14, weight: .bold)
        addSubview(title)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = NSColor.black.cgColor
        addSubview(border)
        
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
        addSubview(scroll)
        
        cancel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        cancel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        title.centerYAnchor.constraint(equalTo: cancel.centerYAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: cancel.leftAnchor, constant: -10).isActive = true
        
        border.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor, constant: -2).isActive = true
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -2).isActive = true
        
        App.repository?.log { items in
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
    
    required init?(coder: NSCoder) { return nil }
}
