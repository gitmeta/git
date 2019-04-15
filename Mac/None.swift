import AppKit

class None: NSView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        alphaValue = 0
        
        let warning = NSImageView()
        warning.translatesAutoresizingMaskIntoConstraints = false
        warning.image = NSImage(named: "not")
        warning.imageScaling = .scaleNone
        addSubview(warning)
        
        let message = Label(.local("None.message"))
        message.font = .light(14)
        message.textColor = NSColor(white: 1, alpha: 0.5)
        message.alignment = .center
        addSubview(message)
        
        let start = Button(.local("None.start"), color: .black, target: App.shared, action: #selector(App.shared.start))
        start.layer!.backgroundColor = NSColor.halo.cgColor
        start.width.constant = 82
        start.height.constant = 36
        addSubview(start)
        
        warning.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40).isActive = true
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
}
