import Git
import AppKit

class Display: NSView {
    private weak var create: Button!
    private weak var message: Label!
    private weak var image: NSImageView!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        image.image = NSImage(named: "logo")
        addSubview(image)
        self.image = image
        
        let message = Label()
        message.font = .systemFont(ofSize: 14, weight: .medium)
        message.textColor = NSColor(white: 1, alpha: 0.6)
        message.alignment = .center
        addSubview(message)
        self.message = message

        let create = Button.Image(NSApp, action: #selector(App.create))
        create.off = NSImage(named: "createOff")
        create.on = NSImage(named: "createOn")
        create.width.constant = 90
        create.height.constant = 90
        create.isHidden = true
        addSubview(create)
        self.create = create
        
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        message.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        message.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
        message.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        create.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        create.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 20).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func logo() {
        alphaValue = 1
        image.image = NSImage(named: "logo")
        message.stringValue = ""
        create.isHidden = true
    }
    
    func repository() {
        alphaValue = 0
        image.image = nil
        message.stringValue = ""
        create.isHidden = true
    }
    
    func notRepository() {
        alphaValue = 1
        image.image = NSImage(named: "error")
        message.stringValue = .local("Display.notRepository")
        create.isHidden = false
    }
    
    func upToDate() {
        alphaValue = 1
        image.image = NSImage(named: "updated")
        message.stringValue = .local("Display.upToDate")
        create.isHidden = true
    }
}
