import Git
import AppKit

class Commit: Sheet {
    private weak var text: NSTextView!
    
    @discardableResult override init() {
        super.init()
        let blur = NSVisualEffectView(frame: .zero)
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.material = .dark
        blur.blendingMode = .withinWindow
        addSubview(blur)
        
        let save = Button.Image(self, action: #selector(self.save))
        save.off = NSImage(named: "commitOff")
        save.on = NSImage(named: "commitOn")
        save.width.constant = 65
        save.height.constant = 65
        addSubview(save)
        
        let cancel = Button.Image(self, action: #selector(close))
        cancel.off = NSImage(named: "cancelOff")
        cancel.on = NSImage(named: "cancelOn")
        cancel.width.constant = 50
        cancel.height.constant = 50
        addSubview(cancel)
        
        let title = Label(.local("Commit.title"))
        title.textColor = .halo
        title.font = .bold(20)
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
        
        cancel.centerYAnchor.constraint(equalTo: save.centerYAnchor).isActive = true
        cancel.rightAnchor.constraint(equalTo: save.leftAnchor).isActive = true
        
        save.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        save.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        
        title.bottomAnchor.constraint(equalTo: scroll.topAnchor, constant: -5).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 25).isActive = true
        
        scroll.topAnchor.constraint(equalTo: save.bottomAnchor).isActive = true
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
        do {
            let user = try User(App.session.name, email: App.session.email)
            App.repository?.commit(
                (App.window.list.documentView!.subviews as! [Item]).filter({ $0.stage.checked }).map { $0.url },
                user: user, message: text.string, error: {
                    App.window.alert.error($0.localizedDescription)
            }) { [weak self] in
                App.window.refresh()
                App.window.alert.commit(self?.text.string ?? "")
                self?.close()
            }
        } catch {
            App.window.alert.error(error.localizedDescription)
        }
    }
}
