import Git
import UIKit

final class Home: UIView {
    final class Item: UIView {
        let url: URL
        private(set) weak var check: UIButton!
        private(set) weak var badge: UIView!
        private(set) weak var label: UILabel!
        
        fileprivate init(_ url: URL, status: Status) {
            self.url = url
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 2
            label.attributedText = {
                let path = url.deletingLastPathComponent().path.dropFirst(Hub.session.url.path.count + 1)
                if !path.isEmpty {
                    $0.append(NSAttributedString(string: "\(path) ", attributes: [.font: UIFont.light(14), .foregroundColor:
                        UIColor.halo]))
                }
                $0.append(NSAttributedString(string: url.lastPathComponent, attributes: [.font: UIFont.bold(14), .foregroundColor: UIColor.halo]))
                return $0
            } (NSMutableAttributedString())
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            self.label = label
            
            let badge = UIView()
            badge.isUserInteractionEnabled = false
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.layer.cornerRadius = 4
            badge.isUserInteractionEnabled = false
            addSubview(badge)
            self.badge = badge
            
            let hashtag = UILabel()
            hashtag.translatesAutoresizingMaskIntoConstraints = false
            hashtag.textColor = .black
            hashtag.font = .systemFont(ofSize: 11, weight: .light)
            addSubview(hashtag)
            
            let check = UIButton()
            check.translatesAutoresizingMaskIntoConstraints = false
            check.setImage(UIImage(named: "checkOff"), for: .normal)
            check.setImage(UIImage(named: "checkOn"), for: .selected)
            check.isSelected = true
            addSubview(check)
            self.check = check
            
            let border = UIView()
            border.isUserInteractionEnabled = false
            border.translatesAutoresizingMaskIntoConstraints = false
            border.backgroundColor = UIColor.halo.withAlphaComponent(0.4)
            addSubview(border)
            
            switch status {
            case .deleted:
                badge.backgroundColor = .deleted
                hashtag.text = .local("Home.deleted")
            case .added:
                badge.backgroundColor = .added
                hashtag.text = .local("Home.added")
            case .modified:
                badge.backgroundColor = .modified
                hashtag.text = .local("Home.modified")
            case .untracked:
                badge.backgroundColor = .untracked
                hashtag.text = .local("Home.untracked")
            }
            
            heightAnchor.constraint(equalToConstant: 66).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: badge.leftAnchor, constant: -10).isActive = true
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
            
            badge.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            badge.rightAnchor.constraint(equalTo: check.leftAnchor, constant: 10).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 20).isActive = true
            badge.leftAnchor.constraint(equalTo: hashtag.leftAnchor, constant: -9).isActive = true
            
            hashtag.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            hashtag.rightAnchor.constraint(equalTo: badge.rightAnchor, constant: -9).isActive = true
            
            check.widthAnchor.constraint(equalToConstant: 55).isActive = true
            check.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            check.topAnchor.constraint(equalTo: topAnchor).isActive = true
            check.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private(set) weak var list: UIScrollView!
    private weak var image: UIImageView!
    private weak var button: UIButton!
    private weak var browse: UIButton!
    private weak var refresh: UIButton!
    private weak var reset: UIButton!
    private weak var cloud: UIButton!
    private weak var label: UILabel!
    private weak var count: UILabel!
    private weak var bottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; bottom.isActive = true } }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let border = UIView()
        border.isUserInteractionEnabled = true
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        addSubview(border)
        
        let browse = Button.Yes(.local("Home.directory"))
        browse.addTarget(app, action: #selector(app.browse), for: .touchUpInside)
        browse.isHidden = true
        addSubview(browse)
        self.browse = browse
        
        let refresh = Button.Yes(.local("Home.refresh"))
        refresh.addTarget(app, action: #selector(app.refresh), for: .touchUpInside)
        refresh.isHidden = true
        addSubview(refresh)
        self.refresh = refresh
        
        let list = UIScrollView()
        list.translatesAutoresizingMaskIntoConstraints = false
        list.alwaysBounceVertical = true
        addSubview(list)
        self.list = list
        
        let image = UIImageView(image: UIImage(named: "loading"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        addSubview(image)
        self.image = image
        
        let button = Button.Yes("")
        button.isHidden = true
        addSubview(button)
        self.button = button
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .halo
        label.textAlignment = .center
        label.numberOfLines = 0
        addSubview(label)
        self.label = label
        
        let count = UILabel()
        count.translatesAutoresizingMaskIntoConstraints = false
        count.font = .systemFont(ofSize: 12, weight: .regular)
        count.textAlignment = .right
        count.textColor = .halo
        addSubview(count)
        self.count = count
        
        let reset = UIButton()
        reset.translatesAutoresizingMaskIntoConstraints = false
        reset.isHidden = true
        reset.setImage(UIImage(named: "reset"), for: .normal)
        reset.setImage(UIImage(named: "reset")!.withRenderingMode(.alwaysTemplate), for: .highlighted)
        reset.imageView!.contentMode = .center
        reset.imageView!.clipsToBounds = true
        reset.imageView!.tintColor = UIColor.halo.withAlphaComponent(0.2)
        reset.addTarget(self, action: #selector(reseting), for: .touchUpInside)
        addSubview(reset)
        self.reset = reset
        
        let cloud = UIButton()
        cloud.translatesAutoresizingMaskIntoConstraints = false
        cloud.isHidden = true
        cloud.setImage(UIImage(named: "cloud"), for: .normal)
        cloud.setImage(UIImage(named: "cloud")!.withRenderingMode(.alwaysTemplate), for: .highlighted)
        cloud.imageView!.contentMode = .center
        cloud.imageView!.clipsToBounds = true
        cloud.imageView!.tintColor = UIColor.halo.withAlphaComponent(0.2)
        cloud.addTarget(self, action: #selector(clouding), for: .touchUpInside)
        addSubview(cloud)
        self.cloud = cloud
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: count.leftAnchor, constant: -10).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.bottomAnchor.constraint(equalTo: topAnchor, constant: 55).isActive = true
        
        browse.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        browse.centerYAnchor.constraint(equalTo: topAnchor, constant: 27).isActive = true
        
        refresh.rightAnchor.constraint(equalTo: browse.leftAnchor, constant: -10).isActive = true
        refresh.centerYAnchor.constraint(equalTo: browse.centerYAnchor).isActive = true
        
        list.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        list.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 20).isActive = true
        image.widthAnchor.constraint(equalToConstant: 38).isActive = true
        image.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15).isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 260).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5).isActive = true
        
        count.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        count.centerYAnchor.constraint(equalTo: border.centerYAnchor).isActive = true
        
        reset.heightAnchor.constraint(equalToConstant: 45).isActive = true
        reset.widthAnchor.constraint(equalToConstant: 70).isActive = true
        reset.leftAnchor.constraint(equalTo: cloud.rightAnchor, constant: -5).isActive = true
        reset.centerYAnchor.constraint(equalTo: browse.centerYAnchor).isActive = true
        
        cloud.heightAnchor.constraint(equalToConstant: 45).isActive = true
        cloud.widthAnchor.constraint(equalToConstant: 70).isActive = true
        cloud.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        cloud.centerYAnchor.constraint(equalTo: browse.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func update(_ state: State, items: [(URL, Status)] = []) {
        list.subviews.forEach { $0.removeFromSuperview() }
        
        var bottom = list.topAnchor
        items.forEach {
            let item = Item($0.0, status: $0.1)
            item.check.addTarget(self, action: #selector(change(_:)), for: .touchUpInside)
            list.addSubview(item)
            
            item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            item.topAnchor.constraint(equalTo: bottom).isActive = true
            bottom = item.bottomAnchor
        }
        self.bottom = list.bottomAnchor.constraint(greaterThanOrEqualTo: bottom)
        button.removeTarget(self, action: nil, for: .allEvents)
        
        switch state {
        case .loading:
            image.isHidden = false
            image.image = UIImage(named: "loading")
            button.isHidden = true
            browse.isHidden = true
            refresh.isHidden = true
            label.isHidden = true
            count.isHidden = true
            reset.isHidden = true
            cloud.isHidden = true
        case .packed:
            image.isHidden = false
            image.image = UIImage(named: "error")
            button.isHidden = false
            browse.isHidden = false
            refresh.isHidden = false
            button.setTitle(.local("Home.button.packed"), for: [])
            button.addTarget(app, action: #selector(app.unpack), for: .touchUpInside)
            label.isHidden = false
            label.text = .local("Home.label.packed")
            count.isHidden = true
            reset.isHidden = true
            cloud.isHidden = true
        case .ready:
            button.isHidden = true
            browse.isHidden = false
            refresh.isHidden = false
            count.isHidden = false
            label.isHidden = true
            reset.isHidden = false
            cloud.isHidden = false
            recount()
            if items.isEmpty {
                image.isHidden = false
                image.image = UIImage(named: "updated")
            } else {
                image.isHidden = true
            }
        case .create, .first:
            image.isHidden = false
            image.image = UIImage(named: "error")
            button.isHidden = false
            browse.isHidden = true
            refresh.isHidden = true
            button.setTitle(.local("Home.button.create"), for: [])
            button.addTarget(app, action: #selector(app.create), for: .touchUpInside)
            label.isHidden = false
            label.text = .local("Home.label.create")
            count.isHidden = true
            reset.isHidden = true
            cloud.isHidden = false
        }
    }
    
    private func recount() {
        count.text = {
            "\($0.filter({ $0.check.isSelected }).count)/\($0.count)"
        } (list.subviews.compactMap({ $0 as? Item }))
    }
    
    @objc private func change(_ button: UIButton) {
        button.isSelected.toggle()
        recount()
        UIView.animate(withDuration: 0.3) {
            (button.superview as! Item).label.alpha = button.isSelected ? 1 : 0.4
            (button.superview as! Item).badge.alpha = button.isSelected ? 1 : 0.3
        }
    }
    
    @objc private func reseting() { Reset() }
    
    @objc private func clouding() {
        if Hub.session.purchase.contains(.cloud) {
            Cloud()
        } else {
            app.alert(.local("Alert.purchase"), message: .local("Cloud.purchase"))
        }
    }
}
