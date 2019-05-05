import Git
import AppKit

class Log: Sheet {
    class Item: NSView {
        private weak var label: Label!
        
        fileprivate init(_ commit: Git.Commit) {
            super.init(frame: .zero)
            
            translatesAutoresizingMaskIntoConstraints = false
            
            let label = Label()
            addSubview(label)
            self.label = label
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    @discardableResult override init() {
        super.init()
        let blur = NSVisualEffectView(frame: .zero)
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.material = .ultraDark
        blur.blendingMode = .withinWindow
        addSubview(blur)
        
        let cancel = Button.Image(self, action: #selector(close))
        cancel.off = NSImage(named: "cancelOff")
        cancel.on = NSImage(named: "cancelOn")
        cancel.width.constant = 65
        cancel.height.constant = 65
        addSubview(cancel)
        
        let icon = NSImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = NSImage(named: "history")
        icon.imageScaling = .scaleNone
        addSubview(icon)
        
        let title = Label(.local("Log.title"))
        title.textColor = .halo
        title.font = .systemFont(ofSize: 20, weight: .medium)
        addSubview(title)
        
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
        
        blur.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blur.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blur.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        blur.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        cancel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        cancel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        
        icon.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 35).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        title.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 5).isActive = true
        
        scroll.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 5).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -2).isActive = true
        
        App.repository?.log { [weak self] in
            var top = self?.topAnchor
            $0.forEach {
                let item = Item($0)
            }
        }
    }
    
    required init?(coder: NSCoder) { return nil }
}
