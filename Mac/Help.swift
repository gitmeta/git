import AppKit

final class Help: NSWindow {
    private weak var label: Label!
    private weak var centerX: NSLayoutConstraint!
    private var buttons = [Button]()
    private var images = [NSImageView]()
    private var index = 0
    
    init() {
        super.init(contentRect: NSRect(
            x: (NSScreen.main!.frame.width - 500) / 2, y: (NSScreen.main!.frame.height - 500) / 2, width: 500, height: 500),
                   styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .shade
        isReleasedWhenClosed = false
        
        let title = Label(.local("Help.title"))
        title.textColor = .halo
        title.font = .systemFont(ofSize: 16, weight: .bold)
        contentView!.addSubview(title)
        
        let label = Label()
        label.alignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .light)
        contentView!.addSubview(label)
        self.label = label
        
        var rightImage: NSLayoutXAxisAnchor!
        var rightButton = contentView!.leftAnchor
        (0 ..< 4).forEach {
            let image = NSImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.image = NSImage(named: "onboard\($0)")
            image.imageScaling = .scaleNone
            image.alphaValue = 0
            contentView!.addSubview(image)
            images.append(image)
            
            let button = Button(self, action: #selector(show(_:)))
            button.wantsLayer = true
            button.layer!.backgroundColor = NSColor.halo.cgColor
            contentView!.addSubview(button)
            buttons.append(button)
            
            image.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor, constant: -30).isActive = true
            image.heightAnchor.constraint(equalToConstant: 200).isActive = true
            image.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
            button.heightAnchor.constraint(equalToConstant: 20).isActive = true
            button.widthAnchor.constraint(equalTo: contentView!.widthAnchor, multiplier: 0.25, constant: -2.5).isActive = true
            button.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -1).isActive = true
            button.leftAnchor.constraint(equalTo: rightButton, constant: 2).isActive = true
            rightButton = button.rightAnchor
            
            if $0 == 0 {
                centerX = image.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor)
                centerX.isActive = true
            } else {
                image.leftAnchor.constraint(equalTo: rightImage, constant: 100).isActive = true
            }
            
            
            rightImage = image.rightAnchor
        }
        
        title.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        title.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 10).isActive = true
        
        label.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -50).isActive = true
        label.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        
        DispatchQueue.main.async { [weak self] in self?.display(0) }
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36, 53: close()
        case 123: display(index > 0 ? index - 1 : images.count - 1)
        case 124: display(index < images.count - 1 ? index + 1 : 0)
        default: super.keyDown(with: with)
        }
    }
    
    private func display(_ index: Int) {
        self.index = index
        buttons.enumerated().forEach {
            $0.1.alphaValue = $0.0 == index ? 1 : 0.3
        }
        label.stringValue = .local("Onboard.mac\(index)")
        centerX.constant = CGFloat(-300 * index)
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
