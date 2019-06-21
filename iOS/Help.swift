import UIKit

final class Help: Sheet {
    private weak var label: UILabel!
    private weak var centerX: NSLayoutConstraint!
    private var buttons = [UIButton]()
    private var images = [UIImageView]()
    private var index = 0
    override var height: CGFloat { return 500 }
    
    @discardableResult override init() {
        super.init()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.numberOfLines = 0
        base.addSubview(label)
        self.label = label
        
        var rightImage: NSLayoutXAxisAnchor!
        var rightButton = base.leftAnchor
        let steps = ["help.browse", "help.create", "help.files", "settings", "add", "help.commit", "reset", "history", "cloud", "help.url"]
        steps.enumerated().forEach {
            let image = UIImageView(image: UIImage(named: $0.1))
            image.translatesAutoresizingMaskIntoConstraints = false
            image.contentMode = .center
            image.clipsToBounds = true
            image.alpha = 0
            base.addSubview(image)
            images.append(image)
            
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(show(_:)), for: .touchUpInside)
            button.setImage(UIImage(named: "dot"), for: [])
            button.imageView!.clipsToBounds = true
            button.imageView!.contentMode = .center
            base.addSubview(button)
            buttons.append(button)
            
            image.topAnchor.constraint(equalTo: base.topAnchor, constant: 40).isActive = true
            image.heightAnchor.constraint(equalToConstant: 200).isActive = true
            image.widthAnchor.constraint(equalToConstant: 300).isActive = true
            
            button.heightAnchor.constraint(equalToConstant: 90).isActive = true
            button.widthAnchor.constraint(equalTo: base.widthAnchor, multiplier: 1 / CGFloat(steps.count), constant: -1).isActive = true
            button.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -70).isActive = true
            
            if $0.0 == 0 {
                button.leftAnchor.constraint(equalTo: rightButton, constant: 6).isActive = true
                centerX = image.centerXAnchor.constraint(equalTo: base.centerXAnchor)
                centerX.isActive = true
            } else {
                button.leftAnchor.constraint(equalTo: rightButton).isActive = true
                image.leftAnchor.constraint(equalTo: rightImage, constant: 100).isActive = true
            }
            rightImage = image.rightAnchor
            rightButton = button.rightAnchor
        }
        
        label.topAnchor.constraint(equalTo: base.topAnchor, constant: 240).isActive = true
        label.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 290).isActive = true
        
        DispatchQueue.main.async { [weak self] in self?.display(0) }
    }
    
    required init?(coder: NSCoder) { return nil }
    /*
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
    }*/
    
    private func display(_ index: Int) {
        self.index = index
        buttons.enumerated().forEach { $0.1.alpha = $0.0 == index ? 1 : 0.3 }
        centerX.constant = CGFloat(-400 * index)
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.images.enumerated().forEach {
                $0.1.alpha = $0.0 == index ? 1 : 0
            }
            self?.base.layoutIfNeeded()
        }) { [weak self] _ in self?.label.text = .local("Onboard.mac\(index)") }
    }
    
    @objc private func show(_ button: Button) { display(buttons.firstIndex(of: button)!) }
}
