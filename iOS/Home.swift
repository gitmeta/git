import Git
import UIKit

final class Home: UIView {
    private class Item: UIView {
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
            label.attributedText = {
                let path = url.deletingLastPathComponent().path.dropFirst(Hub.session.url.path.count + 1)
                if !path.isEmpty {
                    $0.append(NSAttributedString(string: "\(path) ", attributes: [.font: UIFont.light(12), .foregroundColor:
                        UIColor.halo.withAlphaComponent(0.9)]))
                }
                $0.append(NSAttributedString(string: url.lastPathComponent, attributes: [.font: UIFont.bold(12), .foregroundColor: UIColor.halo]))
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
            border.backgroundColor = .shade
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
            
            heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: badge.leftAnchor, constant: -20).isActive = true
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
            
            badge.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            badge.rightAnchor.constraint(equalTo: check.leftAnchor, constant: -4).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 20).isActive = true
            badge.leftAnchor.constraint(equalTo: hashtag.leftAnchor, constant: -9).isActive = true
            
            hashtag.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            hashtag.rightAnchor.constraint(equalTo: badge.rightAnchor, constant: -9).isActive = true
            
            check.widthAnchor.constraint(equalToConstant: 32).isActive = true
            check.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
            check.topAnchor.constraint(equalTo: topAnchor).isActive = true
            check.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private weak var list: UIScrollView!
    private weak var image: UIImageView!
    private weak var button: UIButton!
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
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 12, weight: .bold)
        title.textColor = .halo
        title.text = .local("Home.title")
        addSubview(title)
        
        let browse = UIButton()
        browse.translatesAutoresizingMaskIntoConstraints = false
        browse.setTitle(.local("Home.directory"), for: [])
        browse.titleLabel!.font = .systemFont(ofSize: 11, weight: .medium)
        browse.setTitleColor(.black, for: .normal)
        browse.setTitleColor(.init(white: 1, alpha: 0.2), for: .highlighted)
        browse.layer.cornerRadius = 4
        browse.backgroundColor = .halo
        browse.addTarget(app, action: #selector(app.browse), for: .touchUpInside)
        addSubview(browse)
        
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
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.titleLabel!.font = .systemFont(ofSize: 12, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.init(white: 1, alpha: 0.2), for: .highlighted)
        button.layer.cornerRadius = 4
        button.backgroundColor = .halo
        addSubview(button)
        self.button = button
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .init(white: 1, alpha: 0.6)
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
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        title.centerYAnchor.constraint(equalTo: topAnchor, constant: 27).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.bottomAnchor.constraint(equalTo: topAnchor, constant: 55).isActive = true
        
        browse.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        browse.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        browse.widthAnchor.constraint(equalToConstant: 68).isActive = true
        browse.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        list.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        list.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 38).isActive = true
        image.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15).isActive = true
        button.widthAnchor.constraint(equalToConstant: 68).isActive = true
        button.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 260).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 5).isActive = true
        
        count.rightAnchor.constraint(equalTo: browse.leftAnchor, constant: -12).isActive = true
        count.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        
        app.update = { [weak self] in
            guard let self = self else { return }
            self.list.subviews.forEach { $0.removeFromSuperview() }
            
            var bottom = self.list.topAnchor
            $1.forEach {
                let item = Item($0.0, status: $0.1)
                item.check.addTarget(self, action: #selector(self.change(_:)), for: .touchUpInside)
                list.addSubview(item)
                
                item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
                item.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
                item.topAnchor.constraint(equalTo: bottom).isActive = true
                bottom = item.bottomAnchor
            }
            self.bottom = list.bottomAnchor.constraint(greaterThanOrEqualTo: bottom)
            button.removeTarget(self, action: nil, for: .allEvents)
            
            switch $0 {
            case .loading:
                image.isHidden = false
                image.image = UIImage(named: "loading")
                button.isHidden = true
                label.isHidden = true
                count.isHidden = true
            case .packed:
                image.isHidden = false
                image.image = UIImage(named: "error")
                button.isHidden = false
                button.setTitle(.local("Home.button.packed"), for: [])
                button.addTarget(app, action: #selector(app.unpack), for: .touchUpInside)
                label.isHidden = false
                label.text = .local("Home.label.packed")
                count.isHidden = true
            case .ready:
                button.isHidden = true
                count.isHidden = false
                label.isHidden = true
                self.recount()
                if $1.isEmpty {
                    image.isHidden = false
                    image.image = UIImage(named: "updated")
                } else {
                    image.isHidden = true
                }
            case .create:
                image.isHidden = false
                image.image = UIImage(named: "error")
                button.isHidden = false
                button.setTitle(.local("Home.button.create"), for: [])
                button.addTarget(app, action: #selector(app.create), for: .touchUpInside)
                label.isHidden = false
                label.text = .local("Home.label.create")
                count.isHidden = true
            case .first:
                image.isHidden = false
                image.image = UIImage(named: "error")
                button.isHidden = true
                label.isHidden = false
                label.text = .local("Home.label.first")
                count.isHidden = true
            }
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc private func change(_ button: UIButton) {
        button.isSelected.toggle()
        recount()
        UIView.animate(withDuration: 0.3) {
            (button.superview as! Item).label.alpha = button.isSelected ? 1 : 0.4
            (button.superview as! Item).badge.alpha = button.isSelected ? 1 : 0.3
        }
    }
    
    private func recount() {
        count.text = {
            "\($0.filter({ $0.check.isSelected }).count)/\($0.count)"
        } (list.subviews.compactMap({ $0 as? Item }))
    }
}
