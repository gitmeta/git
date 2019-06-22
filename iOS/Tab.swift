import UIKit

final class Tab: UIView {
    final class Button: UIButton {
        let target: (() -> Void)
        fileprivate weak var tab: Tab!
        
        init(_ image: String, target: @escaping(() -> Void)) {
            self.target = target
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            setImage(UIImage(named: image), for: .selected)
            setImage(UIImage(named: image)!.withRenderingMode(.alwaysTemplate), for: .normal)
            imageView!.clipsToBounds = true
            imageView!.contentMode = .center
            imageView!.tintColor = UIColor.halo.withAlphaComponent(0.4)
            addTarget(self, action: #selector(choose), for: .touchUpInside)
        }
        
        required init?(coder: NSCoder) { return nil }
        @objc func choose() { tab.choose(self) }
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
