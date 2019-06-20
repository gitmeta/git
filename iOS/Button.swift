import UIKit

class Button: UIButton {
    final class Yes: Button {
        override init(_ title: String) {
            super.init(title)
            setTitleColor(.black, for: .normal)
            setTitleColor(.init(white: 1, alpha: 0.2), for: .highlighted)
            layer.cornerRadius = 4
            backgroundColor = .halo
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    final class No: Button {
        override init(_ title: String) {
            super.init(title)
            setTitleColor(.init(white: 1, alpha: 0.6), for: .normal)
            setTitleColor(.init(white: 1, alpha: 0.2), for: .highlighted)
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    init(_ title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel!.font = .systemFont(ofSize: 11, weight: .medium)
        setTitle(title, for: [])
        widthAnchor.constraint(equalToConstant: 80).isActive = true
        heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
}
