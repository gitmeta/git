import AppKit

class List: NSView {
    private weak var warning: NSImageView!
    private weak var message: Label!
    private weak var start: Button!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let warning = NSImageView()
        warning.translatesAutoresizingMaskIntoConstraints = false
        warning.image = NSImage(named: "not")
        warning.imageScaling = .scaleNone
        warning.isHidden = true
        addSubview(warning)
        self.warning = warning
        
        let message = Label()
        message.font = .light(14)
        message.textColor = NSColor(white: 1, alpha: 0.5)
        message.alignment = .center
        message.isHidden = true
        addSubview(message)
        self.message = message
        
        let start = Button(.local("List.start"), color: .black, target: App.shared, action: #selector(App.shared.start))
        start.layer!.backgroundColor = NSColor.halo.cgColor
        start.isHidden = true
        start.width.constant = 90
        start.height.constant = 40
        addSubview(start)
        self.start = start
        
        warning.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        warning.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        warning.widthAnchor.constraint(equalToConstant: 42).isActive = true
        warning.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        message.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        message.topAnchor.constraint(equalTo: warning.bottomAnchor, constant: 25).isActive = true
        message.widthAnchor.constraint(equalToConstant: 280).isActive = true
        
        start.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        start.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 20).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func update() {
        isHidden = false
        App.shared.repository == nil ? not() : load()
    }
    
    private func not() {
        warning.isHidden = false
        message.isHidden = false
        start.isHidden = false
        message.stringValue = .local("List.not")
    }
    
    private func load() {
        warning.isHidden = true
        message.isHidden = true
        start.isHidden = true
    }
}
