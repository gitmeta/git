import AppKit

class Onboard: Sheet {
    private weak var label: Label!
    private weak var centerX: NSLayoutConstraint!
    private weak var point0: Button!
    private weak var point1: Button!
    private weak var point2: Button!
    private weak var image0: NSImageView!
    private weak var image1: NSImageView!
    private weak var image2: NSImageView!
    private var index = 0
    
    @discardableResult override init() {
        super.init()
        layer!.backgroundColor = NSColor.black.cgColor
        
        let done = Button.Text(self, action: #selector(close))
        done.label.stringValue = .local("Onboard.done")
        done.label.textColor = NSColor(white: 1, alpha: 0.5)
        done.label.font = .systemFont(ofSize: 16, weight: .medium)
        done.width.constant = 100
        done.height.constant = 40
        addSubview(done)
        
        let label = Label()
        label.alignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .ultraLight)
        addSubview(label)
        self.label = label
        
        let image0 = NSImageView()
        image0.translatesAutoresizingMaskIntoConstraints = false
        image0.image = NSImage(named: "onboard0")
        image0.imageScaling = .scaleNone
        image0.alphaValue = 0
        addSubview(image0)
        self.image0 = image0
        
        let image1 = NSImageView()
        image1.translatesAutoresizingMaskIntoConstraints = false
        image1.image = NSImage(named: "onboard1")
        image1.imageScaling = .scaleNone
        image1.alphaValue = 0
        addSubview(image1)
        self.image1 = image1
        
        let image2 = NSImageView()
        image2.translatesAutoresizingMaskIntoConstraints = false
        image2.image = NSImage(named: "onboard2")
        image2.imageScaling = .scaleNone
        image2.alphaValue = 0
        addSubview(image2)
        self.image2 = image2
        
        let point0 = Button(self, action: #selector(show0))
        point0.wantsLayer = true
        point0.layer!.backgroundColor = NSColor.halo.cgColor
        point0.layer!.cornerRadius = 10
        point0.width.constant = 20
        point0.height.constant = 20
        addSubview(point0)
        self.point0 = point0
        
        let point1 = Button(self, action: #selector(show1))
        point1.wantsLayer = true
        point1.layer!.backgroundColor = NSColor.halo.cgColor
        point1.layer!.cornerRadius = 10
        point1.width.constant = 20
        point1.height.constant = 20
        addSubview(point1)
        self.point1 = point1
        
        let point2 = Button(self, action: #selector(show2))
        point2.wantsLayer = true
        point2.layer!.backgroundColor = NSColor.halo.cgColor
        point2.layer!.cornerRadius = 10
        point2.width.constant = 20
        point2.height.constant = 20
        addSubview(point2)
        self.point2 = point2
        
        image0.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100).isActive = true
        image0.heightAnchor.constraint(equalToConstant: 200).isActive = true
        image0.widthAnchor.constraint(equalToConstant: 200).isActive = true
        centerX = image0.centerXAnchor.constraint(equalTo: centerXAnchor)
        centerX.isActive = true
        
        image1.leftAnchor.constraint(equalTo: image0.rightAnchor).isActive = true
        image1.centerYAnchor.constraint(equalTo: image0.centerYAnchor).isActive = true
        image1.heightAnchor.constraint(equalTo: image0.heightAnchor).isActive = true
        image1.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        image2.leftAnchor.constraint(equalTo: image1.rightAnchor).isActive = true
        image2.centerYAnchor.constraint(equalTo: image0.centerYAnchor).isActive = true
        image2.heightAnchor.constraint(equalTo: image0.heightAnchor).isActive = true
        image2.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        label.topAnchor.constraint(equalTo: image0.bottomAnchor, constant: 30).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        point1.topAnchor.constraint(equalTo: image0.bottomAnchor, constant: 150).isActive = true
        point1.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        point0.topAnchor.constraint(equalTo: point1.topAnchor).isActive = true
        point0.rightAnchor.constraint(equalTo: point1.leftAnchor, constant: -20).isActive = true
        
        point2.topAnchor.constraint(equalTo: point1.topAnchor).isActive = true
        point2.leftAnchor.constraint(equalTo: point1.rightAnchor, constant: 20).isActive = true
        
        done.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        done.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        DispatchQueue.main.async { [weak self] in self?.show0() }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36: close()
        case 123:
            switch index {
            case 0: show2()
            case 1: show0()
            default: show1()
            }
        case 124:
            switch index {
            case 0: show1()
            case 1: show2()
            default: show0()
            }
        default: super.keyDown(with: with)
        }
    }
    
    @objc private func show0() {
        index = 0
        point0.alphaValue = 1
        point1.alphaValue = 0.3
        point2.alphaValue = 0.3
        label.stringValue = .local("Onboard.0")
        centerX.constant = 0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1
            context.allowsImplicitAnimation = true
            image0.alphaValue = 1
            image1.alphaValue = 0
            image2.alphaValue = 0
            layoutSubtreeIfNeeded()
        }) { [weak self] in
            self?.point0.isHidden = false
        }
    }
    
    @objc private func show1() {
        index = 1
        point0.alphaValue = 0.3
        point1.alphaValue = 1
        point2.alphaValue = 0.3
        label.stringValue = .local("Onboard.1")
        centerX.constant = -200
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1
            context.allowsImplicitAnimation = true
            image0.alphaValue = 0
            image1.alphaValue = 1
            image2.alphaValue = 0
            layoutSubtreeIfNeeded()
        }) { }
    }
    
    @objc private func show2() {
        index = 2
        point0.alphaValue = 0.3
        point1.alphaValue = 0.3
        point2.alphaValue = 1
        label.stringValue = .local("Onboard.2")
        centerX.constant = -400
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1
            context.allowsImplicitAnimation = true
            image0.alphaValue = 0
            image1.alphaValue = 0
            image2.alphaValue = 1
            layoutSubtreeIfNeeded()
        }) { }
    }
}
