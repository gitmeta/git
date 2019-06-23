import UIKit

final class Help: Sheet {
    private weak var label: UILabel!
    private weak var centerX: NSLayoutConstraint!
    private var buttons = [UIButton]()
    private var images = [UIImageView]()
    private var index = 0

    @discardableResult init() {
        super.init(480)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.numberOfLines = 0
        base.addSubview(label)
        self.label = label
        
        let close = Button.No(.local("Help.close"))
        close.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        base.addSubview(close)
        
        var rightImage: NSLayoutXAxisAnchor!
        var rightButton = base.leftAnchor
        let steps = ["help.container", "help.create", "help.home", "settings", "add", "help.commit", "reset", "history", "cloud", "help.git"]
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
            
            image.topAnchor.constraint(equalTo: base.topAnchor, constant: 20).isActive = true
            image.heightAnchor.constraint(equalToConstant: 200).isActive = true
            image.widthAnchor.constraint(equalToConstant: 300).isActive = true
            
            button.heightAnchor.constraint(equalToConstant: 90).isActive = true
            button.widthAnchor.constraint(equalTo: base.widthAnchor, multiplier: 1 / CGFloat(steps.count), constant: -4).isActive = true
            button.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -60).isActive = true
            
            if $0.0 == 0 {
                button.leftAnchor.constraint(equalTo: rightButton, constant: 20).isActive = true
                centerX = image.centerXAnchor.constraint(equalTo: base.centerXAnchor)
                centerX.isActive = true
            } else {
                button.leftAnchor.constraint(equalTo: rightButton).isActive = true
                image.leftAnchor.constraint(equalTo: rightImage, constant: 100).isActive = true
            }
            rightImage = image.rightAnchor
            rightButton = button.rightAnchor
        }
        
        label.topAnchor.constraint(equalTo: base.topAnchor, constant: 230).isActive = true
        label.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 290).isActive = true
        
        close.centerXAnchor.constraint(equalTo: base.centerXAnchor).isActive = true
        close.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: -20).isActive = true
        display(0)
    }
    
    required init?(coder: NSCoder) { return nil }
    
    private func display(_ index: Int) {
        label.text = .local("Onboard.ios\(index)")
        base.layoutIfNeeded()
        self.index = index
        buttons.enumerated().forEach { $0.1.alpha = $0.0 == index ? 1 : 0.3 }
        centerX.constant = CGFloat(-400 * index)
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.images.enumerated().forEach {
                $0.1.alpha = $0.0 == index ? 1 : 0
            }
            self?.base.layoutIfNeeded()
        }
    }
    
    @objc private func show(_ button: Button) { display(buttons.firstIndex(of: button)!) }
}
