import UIKit

final class Tab: UIView {
    private final class Button: UIButton {
        weak var target: UIView!
        
        init(_ image: UIImage) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            setImage(image, for: .selected)
            setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            imageView!.clipsToBounds = true
            imageView!.contentMode = .center
            imageView!.tintColor = UIColor.halo.withAlphaComponent(0.4)
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let border = UIView()
        border.isUserInteractionEnabled = true
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        addSubview(border)
        
        var left = leftAnchor
        
        ([("settings", app.home), ("market", app.market), ("home", app.home), ("add", app.add), ("history", app.home)] as [(String, UIView)]).forEach {
            let button = Button(UIImage(named: $0.0)!)
            button.target = $0.1
            button.addTarget(self, action: #selector(choose(_:)), for: .touchUpInside)
            addSubview(button)
            
            button.leftAnchor.constraint(equalTo: left).isActive = true
            button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2).isActive = true
            button.topAnchor.constraint(equalTo: topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            left = button.rightAnchor
            
            if $0.0 == "home" {
                button.isSelected = true
            }
        }
        
        heightAnchor.constraint(equalToConstant: 62).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc private func choose(_ button: Button) {
        subviews.compactMap({ $0 as? Button }).forEach({ $0.isSelected = $0 === button })
        app.show(button.target)
    }
}
