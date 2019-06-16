import UIKit

final class Tab: UIView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let border = UIView()
        border.isUserInteractionEnabled = true
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        addSubview(border)
        
        var left = leftAnchor
        
        [("home", #selector(add)), ("add", #selector(add)), ("reset", #selector(add)), ("cloud", #selector(add)), ("history", #selector(add)), ("settings", #selector(add))].forEach {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: $0.1, for: .touchUpInside)
            button.setImage(UIImage(named: $0.0), for: .selected)
            button.setImage(UIImage(named: $0.0)!.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView!.clipsToBounds = true
            button.imageView!.contentMode = .center
            button.imageView!.tintColor = UIColor.halo.withAlphaComponent(0.4)
            addSubview(button)
            
            button.leftAnchor.constraint(equalTo: left).isActive = true
            button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.166).isActive = true
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
    private func select(_ button: UIButton) { subviews.compactMap({ $0 as? UIButton }).forEach({ $0.isSelected = $0 === button }) }
    
    @objc private func add(_ button: UIButton) {
        guard !button.isSelected else { return }
        select(button)
        app.show(Home())
    }
}
