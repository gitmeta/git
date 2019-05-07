import UIKit

class Bar: UIControl {
    class Location: Bar {
        override init() {
            super.init()
            label.text = .local("Bar.location")
            label.font = .systemFont(ofSize: 14, weight: .bold)
            label.textColor = .white
            background.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            background.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    class Branch: Bar {
        override init() {
            super.init()
            label.font = .systemFont(ofSize: 14, weight: .bold)
            label.textColor = UIColor(white: 1, alpha: 0.8)
            background.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            background.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private(set) weak var label: UILabel!
    private weak var background: UIView!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        layer.cornerRadius = 4
        
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = .halo
        background.alpha = 0.4
        background.isUserInteractionEnabled = false
        addSubview(background)
        self.background = background
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        self.label = label
        
        background.topAnchor.constraint(equalTo: topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 10).isActive = true
        label.leftAnchor.constraint(equalTo: background.leftAnchor, constant: 16).isActive = true
        label.rightAnchor.constraint(equalTo: background.rightAnchor, constant: -16).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    override var isHighlighted: Bool { didSet { hover() } }
    override var isSelected: Bool { didSet { hover() } }
    private func hover() { background.alpha = isHighlighted || isSelected ? 0.7 : 0.4 }
}
