import Git
import AppKit

class Display: NSView {
    private weak var create: Button!
    private weak var unpack: Button!
    private weak var message: Label!
    private weak var image: NSImageView!
    private weak var spinner: NSImageView!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let spinner = NSImageView()
        spinner.isHidden = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.imageScaling = .scaleNone
        spinner.image = NSImage(named: "loading")
        addSubview(spinner)
        self.spinner = spinner
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        image.image = NSImage(named: "logo")
        addSubview(image)
        self.image = image
        
        let message = Label()
        message.font = .systemFont(ofSize: 12, weight: .regular)
        message.textColor = NSColor(white: 1, alpha: 0.6)
        message.alignment = .center
        addSubview(message)
        self.message = message

        let create = Button.Text(self, action: #selector(createRepository))
        create.wantsLayer = true
        create.layer!.backgroundColor = NSColor.halo.cgColor
        create.layer!.cornerRadius = 6
        create.label.stringValue = .local("Display.create")
        create.label.textColor = .black
        create.label.font = .systemFont(ofSize: 14, weight: .medium)
        create.width.constant = 70
        create.height.constant = 28
        create.isHidden = true
        addSubview(create)
        self.create = create
        
        let unpack = Button.Text(self, action: #selector(unpackRepository))
        unpack.wantsLayer = true
        unpack.layer!.backgroundColor = NSColor.halo.cgColor
        unpack.layer!.cornerRadius = 6
        unpack.label.stringValue = .local("Display.unpack")
        unpack.label.textColor = .black
        unpack.label.font = .systemFont(ofSize: 14, weight: .medium)
        unpack.width.constant = 70
        unpack.height.constant = 28
        unpack.isHidden = true
        addSubview(unpack)
        self.unpack = unpack
        
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        message.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        message.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
        message.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        create.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        create.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 30).isActive = true
        
        unpack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        unpack.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 30).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func loading() {
        alphaValue = 1
        image.image = nil
        spinner.isHidden = false
        message.stringValue = ""
        create.isHidden = true
        unpack.isHidden = true
    }
    
    func repository() {
        alphaValue = 0
        image.image = nil
        spinner.isHidden = true
        message.stringValue = ""
        create.isHidden = true
        unpack.isHidden = true
    }
    
    func notRepository() {
        alphaValue = 1
        image.image = NSImage(named: "error")
        spinner.isHidden = true
        message.stringValue = .local("Display.notRepository")
        create.isHidden = false
        unpack.isHidden = true
    }
    
    func upToDate() {
        alphaValue = 1
        image.image = NSImage(named: "updated")
        spinner.isHidden = true
        message.stringValue = .local("Display.upToDate")
        create.isHidden = true
        unpack.isHidden = true
    }
    
    func packed() {
        alphaValue = 1
        image.image = NSImage(named: "error")
        spinner.isHidden = true
        message.stringValue = .local("Display.packed")
        create.isHidden = true
        unpack.isHidden = false
    }
    
    @objc private func createRepository() {
        loading()
        Hub.create(Hub.session.url, error: {
            App.window.alert.error($0.localizedDescription)
        }) { App.repository = $0 }
    }
    
    @objc private func unpackRepository() {
        loading()
        App.repository?.unpack({
            App.window.refresh()
            App.window.alert.error($0.localizedDescription)
        }) {
            App.window.alert.update(.local("Display.unpacked"))
        }
    }
}
