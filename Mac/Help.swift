import AppKit

final class Help: NSWindow {
    private weak var label: Label!
    private weak var centerX: NSLayoutConstraint!
    private var buttons = [Button]()
    private var images = [NSImageView]()
    private var index = 0
    
    init() {
        super.init(contentRect: NSRect(
            x: (NSScreen.main!.frame.width - 540) / 2, y: (NSScreen.main!.frame.height - 500) / 2, width: 540, height: 500),
                   styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .shade
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        contentView!.addSubview(border)
        
        let title = Label(.local("Help.title"))
        title.textColor = .halo
        title.font = .systemFont(ofSize: 14, weight: .bold)
        contentView!.addSubview(title)
        
        let label = Label()
        label.textColor = .init(white: 1, alpha: 0.8)
        label.font = .systemFont(ofSize: 16, weight: .light)
        contentView!.addSubview(label)
        self.label = label
        
        var rightImage: NSLayoutXAxisAnchor!
        var rightButton = contentView!.leftAnchor
        let steps = ["help.browse", "help.create", "help.files", "settings", "add", "help.commit", "reset", "history", "cloud", "help.url"]
        steps.enumerated().forEach {
            let image = NSImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.image = NSImage(named: $0.1)
            image.imageScaling = .scaleNone
            image.alphaValue = 0
            contentView!.addSubview(image)
            images.append(image)
            
            let button = Button.Image(self, action: #selector(show(_:)))
            button.image.image = NSImage(named: "dot")
            contentView!.addSubview(button)
            buttons.append(button)
            
            image.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor, constant: -100).isActive = true
            image.heightAnchor.constraint(equalToConstant: 200).isActive = true
            image.widthAnchor.constraint(equalToConstant: 400).isActive = true
            
            button.heightAnchor.constraint(equalToConstant: 80).isActive = true
            button.widthAnchor.constraint(equalTo: contentView!.widthAnchor, multiplier: 1 / CGFloat(steps.count), constant: -7).isActive = true
            button.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
            
            if $0.0 == 0 {
                button.leftAnchor.constraint(equalTo: rightButton, constant: 30).isActive = true
                centerX = image.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor)
                centerX.isActive = true
            } else {
                button.leftAnchor.constraint(equalTo: rightButton).isActive = true
                image.leftAnchor.constraint(equalTo: rightImage, constant: 100).isActive = true
            }
            rightImage = image.rightAnchor
            rightButton = button.rightAnchor
        }
        
        title.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 18).isActive = true
        title.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -20).isActive = true
        
        border.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 39).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        label.topAnchor.constraint(equalTo: contentView!.centerYAnchor, constant: 50).isActive = true
        label.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 480).isActive = true
        
        DispatchQueue.main.async { [weak self] in self?.display(0) }
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 13:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                close()
            } else {
                super.keyDown(with: with)
            }
        case 36, 53: close()
        case 123: display(index > 0 ? index - 1 : images.count - 1)
        case 124: display(index < images.count - 1 ? index + 1 : 0)
        default: super.keyDown(with: with)
        }
    }
    
    private func display(_ index: Int) {
        self.index = index
        buttons.enumerated().forEach {
            $0.1.alphaValue = $0.0 == index ? 1 : 0.12
        }
        label.stringValue = .local("Onboard.mac\(index)")
        centerX.constant = CGFloat(-500 * index)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1
            context.allowsImplicitAnimation = true
            images.enumerated().forEach {
                $0.1.alphaValue = $0.0 == index ? 1 : 0
            }
            contentView!.layoutSubtreeIfNeeded()
        }) { }
    }
    
    @objc private func show(_ button: Button) { display(buttons.firstIndex(of: button)!) }
}
