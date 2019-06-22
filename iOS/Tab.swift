import UIKit

final class Tab: UIView {
    final class Button: UIControl {
        let target: (() -> Void)
        fileprivate weak var tab: Tab!
        private weak var indicator: UIView!
        private weak var image: UIImageView!
        
        init(_ image: String, target: @escaping(() -> Void)) {
            self.target = target
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            addTarget(self, action: #selector(choose), for: .touchUpInside)
            
            let indicator = UIView()
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.isUserInteractionEnabled = false
            indicator.backgroundColor = .halo
            addSubview(indicator)
            self.indicator = indicator
            
            let image = UIImageView(image: UIImage(named: image))
            image.translatesAutoresizingMaskIntoConstraints = false
            image.clipsToBounds = true
            image.contentMode = .center
            addSubview(image)
            self.image = image
            
            image.topAnchor.constraint(equalTo: topAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            image.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            indicator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            indicator.widthAnchor.constraint(equalToConstant: 30).isActive = true
            indicator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
        @objc func choose() { tab.choose(self) }
        override var isHighlighted: Bool { didSet { hover() } }
        override var isSelected: Bool { didSet { hover() } }
        
        private func hover() {
            if isSelected || isHighlighted {
                image.alpha = 1
                indicator.isHidden = false
            } else {
                image.alpha = 0.4
                indicator.isHidden = true
            }
        }
    }
    
    private(set) weak var settings: Button!
    private(set) weak var market: Button!
    private(set) weak var home: Button!
    private(set) weak var add: Button!
    private(set) weak var history: Button!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let border = UIView()
        border.isUserInteractionEnabled = true
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        addSubview(border)
        
        let settings = Button("settings", target: app.settings)
        self.settings = settings
        
        let market = Button("market", target: app.market)
        self.market = market
        
        let home = Button("home", target: app.home)
        self.home = home
        
        let add = Button("add", target: app.add)
        self.add = add
        
        let history = Button("history", target: app.history)
        self.history = history
        
        var left = leftAnchor
        [settings, market, home, add, history].forEach {
            $0.tab = self
            addSubview($0)
            
            $0.leftAnchor.constraint(equalTo: left).isActive = true
            $0.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2).isActive = true
            $0.topAnchor.constraint(equalTo: topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            left = $0.rightAnchor
        }
        
        home.choose()
        heightAnchor.constraint(equalToConstant: 62).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    private func choose(_ button: Button) {
        guard !button.isSelected else { return }
        subviews.compactMap({ $0 as? Button }).forEach({ $0.isSelected = $0 === button })
        button.target()
    }
}
