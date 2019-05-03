import Git
import AppKit

class Log: Sheet {
    private weak var text: NSTextView!
    
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
        
        let title = Label(.local("Log.title"))
        title.textColor = .halo
        title.font = .systemFont(ofSize: 22, weight: .bold)
        addSubview(title)
        
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
        
        blur.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blur.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blur.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        blur.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        cancel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        cancel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        
        title.bottomAnchor.constraint(equalTo: scroll.topAnchor, constant: -5).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 23).isActive = true
        
        scroll.topAnchor.constraint(equalTo: cancel.bottomAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -2).isActive = true
        
        text.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        text.heightAnchor.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        
        ready = { [weak self] in
            App.window.makeFirstResponder(self?.text)
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc private func save() {
        App.repository?.commit(
            (App.window.list.documentView!.subviews as! [Item]).filter({ $0.stage.checked }).map { $0.url },
            message: text.string, error: {
                App.window.alert.error($0.localizedDescription)
        }) { [weak self] in
            App.window.refresh()
            App.window.alert.commit(self?.text.string ?? "")
            self?.close()
        }
    }
}
