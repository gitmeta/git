import AppKit

class Onboard: Sheet {
    private weak var label: Label!
    private weak var centerX: NSLayoutConstraint!
    private var buttons = [Button]()
    private var images = [NSImageView]()
    private var index = 0
    
    @discardableResult override init() {
        super.init()
        layer!.backgroundColor = NSColor.black.cgColor
        
        let done = Button.Text(self, action: #selector(close))
        done.wantsLayer = true
        done.layer!.backgroundColor = NSColor.halo.cgColor
        done.layer!.cornerRadius = 6
        done.label.stringValue = .local("Onboard.done")
        done.label.textColor = .black
        done.label.font = .systemFont(ofSize: 16, weight: .medium)
        done.width.constant = 80
        done.height.constant = 34
        addSubview(done)
        
        let label = Label()
        label.alignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .light)
        addSubview(label)
        self.label = label
        
        var rightImage: NSLayoutXAxisAnchor!
        var rightButton: NSLayoutXAxisAnchor!
        (0 ..< 4).forEach {
            let image = NSImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.image = NSImage(named: "onboard\($0)")
            image.imageScaling = .scaleNone
            image.alphaValue = 0
            addSubview(image)
            images.append(image)
            
            let button = Button(self, action: #selector(show(_:)))
            button.wantsLayer = true
            button.layer!.backgroundColor = NSColor.halo.cgColor
            button.layer!.cornerRadius = 10
            button.width.constant = 20
            button.height.constant = 20
            addSubview(button)
            buttons.append(button)
            
            image.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100).isActive = true
            image.heightAnchor.constraint(equalToConstant: 200).isActive = true
            image.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
            button.topAnchor.constraint(equalTo: centerYAnchor, constant: 100).isActive = true
            
            if $0 == 0 {
                centerX = image.centerXAnchor.constraint(equalTo: centerXAnchor)
                centerX.isActive = true
                
                button.rightAnchor.constraint(equalTo: centerXAnchor, constant: -50).isActive = true
            } else {
                image.leftAnchor.constraint(equalTo: rightImage).isActive = true
                button.leftAnchor.constraint(equalTo: rightButton, constant: 20).isActive = true
            }
            
            rightImage = image.rightAnchor
            rightButton = button.rightAnchor
        }
        
        label.topAnchor.constraint(equalTo: centerYAnchor, constant: 25).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        done.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        done.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        DispatchQueue.main.async { [weak self] in self?.display(0) }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36: close()
        case 123:
            display(index > 0 ? index - 1 : images.count - 1)
        case 124:
            display(index < images.count - 1 ? index + 1 : 0)
        default: super.keyDown(with: with)
        }
    }
    
    private func display(_ index: Int) {
        self.index = index
        buttons.enumerated().forEach {
            $0.1.alphaValue = $0.0 == index ? 1 : 0.3
        }
        label.stringValue = .local("Onboard.\(index)")
        centerX.constant = CGFloat(-200 * index)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1
            context.allowsImplicitAnimation = true
            images.enumerated().forEach {
                $0.1.alphaValue = $0.0 == index ? 1 : 0
            }
            layoutSubtreeIfNeeded()
        }) { }
    }
    
    @objc private func show(_ button: Button) { display(buttons.firstIndex(of: button)!) }
}
