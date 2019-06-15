import UIKit

final class Tab: UIView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let border = UIView()
        border.isUserInteractionEnabled = true
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .shade
        addSubview(border)
        
        var left = leftAnchor
        
        [("settings", #selector(app.add)), ("history", #selector(app.add)), ("add", #selector(app.add)), ("reset", #selector(app.add)), ("cloud", #selector(app.add))].forEach {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(app, action: $0.1, for: .touchUpInside)
            button.setImage(UIImage(named: $0.0), for: [])
            button.imageView!.clipsToBounds = true
            button.imageView!.contentMode = .center
            addSubview(button)
            
            button.leftAnchor.constraint(equalTo: left).isActive = true
            button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2).isActive = true
            button.topAnchor.constraint(equalTo: topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            left = button.rightAnchor
        }
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
}
