import AppKit

class Display: NSView {
    private weak var start: Button!
    private weak var message: Label!
    private weak var image: NSImageView!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        image.image = NSImage(named: "upToDate")
        addSubview(image)
        self.image = image
        
        let message = Label()
        message.font = .light(14)
        message.textColor = NSColor(white: 1, alpha: 0.7)
        message.alignment = .center
        addSubview(message)
        self.message = message
        /*
        let start = Button(.local("Display.start"), color: .black, target: App.shared, action: #selector(App.shared.start))
        start.layer!.backgroundColor = NSColor.halo.cgColor
        start.width.constant = 82
        start.height.constant = 36
        start.isHidden = true
        addSubview(start)
        self.start = start
        
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 42).isActive = true
        image.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        message.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        message.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 25).isActive = true
        message.widthAnchor.constraint(equalToConstant: 280).isActive = true
        
        start.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        start.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 20).isActive = true*/
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func hide() {
        alphaValue = 0
        start.isHidden = true
    }
    
    func notRepository() {
        alphaValue = 1
        image.image = NSImage(named: "not")
        message.stringValue = .local("Display.notRepository")
        start.isHidden = false
    }
    
    func upToDate() {
        alphaValue = 1
        image.image = NSImage(named: "upToDate")
        message.stringValue = .local("Display.upToDate")
        start.isHidden = true
    }
}
