import UIKit

final class Bar: UIControl {
    private(set) weak var label: UILabel!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        layer.cornerRadius = 4
        
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = .halo
        background.alpha = 0.6
        background.isUserInteractionEnabled = false
        addSubview(background)
        self.background = background
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .black
        addSubview(label)
        self.label = label
        
        background.topAnchor.constraint(equalTo: topAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 10).isActive = true
        label.leftAnchor.constraint(equalTo: background.leftAnchor, constant: 16).isActive = true
        label.rightAnchor.constraint(equalTo: background.rightAnchor, constant: -16).isActive = true
        label.topAnchor.constraint(equalTo: background.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: background.bottomAnchor).isActive = true
        
        heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    override var isHighlighted: Bool { didSet { hover() } }
    override var isSelected: Bool { didSet { hover() } }
    private func hover() { background.alpha = isHighlighted || isSelected ? 1 : 0.6 }
}
