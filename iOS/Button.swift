import UIKit

class Button: UIButton {
    final class Yes: Button {
        required init?(coder: NSCoder) { return nil }
        override init(_ title: String) {
            super.init(title)
            setTitleColor(.black, for: .normal)
            setTitleColor(.init(white: 1, alpha: 0.2), for: .highlighted)
            layer.cornerRadius = 4
            backgroundColor = .halo
        }
    }
    
    final class No: Button {
        required init?(coder: NSCoder) { return nil }
        override init(_ title: String) {
            super.init(title)
            setTitleColor(.halo, for: .normal)
            setTitleColor(UIColor.halo.withAlphaComponent(0.2), for: .highlighted)
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    fileprivate init(_ title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel!.font = .systemFont(ofSize: 12, weight: .medium)
        setTitle(title, for: [])
        widthAnchor.constraint(equalToConstant: 90).isActive = true
        heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
}
