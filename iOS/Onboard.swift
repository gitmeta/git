import UIKit
/*
class Onboard: Sheet {
    private weak var label: UILabel!
    private weak var centerX: NSLayoutConstraint!
    private var buttons = [UIButton]()
    private var images = [UIImageView]()
    private var index = 0
    
    @discardableResult override init() {
        super.init()
        let done = UIButton()
        done.translatesAutoresizingMaskIntoConstraints = false
        done.addTarget(self, action: #selector(close), for: .touchUpInside)
        done.backgroundColor = .halo
        done.layer.cornerRadius = 6
        done.setTitle(.local("Onboard.done"), for: [])
        done.setTitleColor(.black, for: .normal)
        done.setTitleColor(.init(white: 0, alpha: 0.2), for: .highlighted)
        done.titleLabel!.font = .systemFont(ofSize: 14, weight: .medium)
        addSubview(done)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .regular)
        addSubview(label)
        self.label = label
        
        var rightImage: NSLayoutXAxisAnchor!
        var rightButton: NSLayoutXAxisAnchor!
        (0 ..< 4).forEach {
            let image = UIImageView(image: UIImage(named: "onboard\($0)"))
            image.translatesAutoresizingMaskIntoConstraints = false
            image.clipsToBounds = true
            image.contentMode = .center
            image.alpha = 0
            addSubview(image)
            images.append(image)
            
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(show(_:)), for: .touchUpInside)
            button.setImage(#imageLiteral(resourceName: "dot.pdf"), for: [])
            button.imageView!.clipsToBounds = true
            button.imageView!.contentMode = .center
            addSubview(button)
            buttons.append(button)
            
            image.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -150).isActive = true
            image.heightAnchor.constraint(equalToConstant: 200).isActive = true
            image.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
            button.topAnchor.constraint(equalTo: centerYAnchor, constant: 100).isActive = true
            button.widthAnchor.constraint(equalToConstant: 50).isActive = true
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            if $0 == 0 {
                centerX = image.centerXAnchor.constraint(equalTo: centerXAnchor)
                centerX.isActive = true
                
                button.rightAnchor.constraint(equalTo: centerXAnchor, constant: -50).isActive = true
            } else {
                image.leftAnchor.constraint(equalTo: rightImage, constant: 100).isActive = true
                button.leftAnchor.constraint(equalTo: rightButton).isActive = true
            }
            
            rightImage = image.rightAnchor
            rightButton = button.rightAnchor
        }
        
        label.topAnchor.constraint(equalTo: centerYAnchor, constant: -20).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: 300).isActive = true
        label.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        done.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        done.widthAnchor.constraint(equalToConstant: 90).isActive = true
        done.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        if #available(iOS 11.0, *) {
            done.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        } else {
            done.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
        }
        
        ready = { [weak self] in
            self?.display(0)
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    private func display(_ index: Int) {
        self.index = index
        buttons.enumerated().forEach {
            $0.1.alpha = $0.0 == index ? 1 : 0.3
        }
        label.text = .local("Onboard.iOS\(index)")
        centerX.constant = CGFloat(-300 * index)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.images.enumerated().forEach {
                $0.1.alpha = $0.0 == index ? 1 : 0
            }
            self?.layoutIfNeeded()
        }
    }
    
    @objc private func show(_ button: UIButton) { display(buttons.firstIndex(of: button)!) }
}
*/
