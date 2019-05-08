import Git
import UIKit

class List: UIScrollView {
    class Item: UIView {
        let url: URL
        private(set) weak var stage: UIButton!
        private weak var badge: UIView!
        private weak var label: UILabel!
        private weak var hashtag: UILabel!
        private weak var top: NSLayoutConstraint? { didSet { oldValue?.isActive = false; top?.isActive = true } }
        
        fileprivate init(_ url: URL) {
            self.url = url
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 2
            label.attributedText = {
                let path = url.deletingLastPathComponent().path.dropFirst(Hub.session.url.path.count + 1)
                if !path.isEmpty {
                    $0.append(NSAttributedString(string:
                        "\(path) ", attributes:
                        [.font: UIFont.light(16), .foregroundColor: UIColor.halo.withAlphaComponent(0.8)]))
                }
                $0.append(NSAttributedString(string: url.lastPathComponent, attributes:
                    [.font: UIFont.bold(16), .foregroundColor: UIColor.halo]))
                return $0
            } (NSMutableAttributedString())
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            self.label = label
            
            let badge = UIView()
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.isUserInteractionEnabled = false
            badge.layer.cornerRadius = 4
            addSubview(badge)
            self.badge = badge
            
            let hashtag = UILabel()
            hashtag.translatesAutoresizingMaskIntoConstraints = false
            hashtag.textColor = .black
            hashtag.font = .systemFont(ofSize: 12, weight: .light)
            addSubview(hashtag)
            self.hashtag = hashtag
            
            let stage = UIButton()
            stage.translatesAutoresizingMaskIntoConstraints = false
            stage.addTarget(self, action: #selector(change), for: .touchUpInside)
            stage.setImage(#imageLiteral(resourceName: "checkOff.pdf"), for: .normal)
            stage.setImage(#imageLiteral(resourceName: "checkOn.pdf"), for: .selected)
            stage.isSelected = true
            addSubview(stage)
            self.stage = stage
            
            heightAnchor.constraint(equalToConstant: 54).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: badge.leftAnchor, constant: -20).isActive = true
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
            
            badge.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            badge.rightAnchor.constraint(equalTo: stage.leftAnchor, constant: 10).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 24).isActive = true
            badge.leftAnchor.constraint(equalTo: hashtag.leftAnchor, constant: -9).isActive = true
            
            hashtag.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
            hashtag.rightAnchor.constraint(equalTo: badge.rightAnchor, constant: -9).isActive = true
            
            stage.topAnchor.constraint(equalTo: topAnchor).isActive = true
            stage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            stage.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            stage.widthAnchor.constraint(equalToConstant: 58).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
        
        fileprivate func status(_ current: Status) {
            switch current {
            case .deleted:
                badge.backgroundColor = .deleted
                hashtag.text = .local("Item.deleted")
            case .added:
                badge.backgroundColor = .added
                hashtag.text = .local("Item.added")
            case .modified:
                badge.backgroundColor = .modified
                hashtag.text = .local("Item.modified")
            case .untracked:
                badge.backgroundColor = .untracked
                hashtag.text = .local("Item.untracked")
            }
        }
        
        @objc private func change() {
            stage.isSelected.toggle()
            label.alpha = stage.isSelected ? 1 : 0.2
            badge.alpha = stage.isSelected ? 1 : 0.1
        }
    }
    
    private weak var bottom: NSLayoutConstraint? { didSet { oldValue?.isActive = false; bottom?.isActive = true } }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        alwaysBounceVertical = true
        alpha = 0
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func update(_ items: [(URL, Status)]) {
        subviews.forEach({ $0.removeFromSuperview() })
        var last: Item?
        items.forEach { item in
            let new = Item(item.0)
            new.status(item.1)
            addSubview(new)
            
            if last == nil {
                new.topAnchor.constraint(equalTo: topAnchor).isActive = true
            } else {
                new.topAnchor.constraint(equalTo: last!.bottomAnchor).isActive = true
                
                let border = UIView()
                border.isUserInteractionEnabled = false
                border.backgroundColor = UIColor(white: 0, alpha: 0.3)
                border.translatesAutoresizingMaskIntoConstraints = false
                addSubview(border)
                
                border.topAnchor.constraint(equalTo: new.topAnchor).isActive = true
                border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                border.heightAnchor.constraint(equalToConstant: 1).isActive = true
                border.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            }
            
            new.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            new.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            last = new
        }
        bottom = bottomAnchor.constraint(greaterThanOrEqualTo: last?.bottomAnchor ?? topAnchor, constant: 20)
    }
}
