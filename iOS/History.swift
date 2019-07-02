import Git
import UIKit

final class History: UIView {
    private final class Item: UIView {
        init(_ index: Int, commit: Commit, date: String) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isUserInteractionEnabled = false
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.attributedText = {
                $0.append(NSAttributedString(string: "\(index) ", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor.halo]))
                $0.append(NSAttributedString(string: commit.author.name + " ", attributes: [.font: UIFont.light(18), .foregroundColor: UIColor.halo]))
                $0.append(NSAttributedString(string: date + "\n", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .light), .foregroundColor: UIColor.halo]))
                $0.append(NSAttributedString(string: commit.message, attributes: [.font: UIFont.light(14), .foregroundColor: UIColor.white]))
                return $0
            } (NSMutableAttributedString())
            addSubview(label)
            
            let border = UIView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.isUserInteractionEnabled = false
            border.backgroundColor = UIColor.halo.withAlphaComponent(0.5)
            addSubview(border)
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -16).isActive = true
            label.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -14).isActive = true
            
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private(set) weak var content: UIView?
    private weak var scroll: UIScrollView!
    private weak var loading: UIImageView!
    private weak var branch: UILabel!
    private weak var button: UIButton!
    private let formatter = DateFormatter()
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        let loading = UIImageView(image: UIImage(named: "loading"))
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.contentMode = .center
        loading.clipsToBounds = true
        addSubview(loading)
        self.loading = loading
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 12, weight: .bold)
        title.textColor = .halo
        title.text = .key("History.title")
        addSubview(title)
        
        let border = UIView()
        border.isUserInteractionEnabled = true
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        addSubview(border)
        
        let button = Button.Yes(.key("History.refresh"))
        button.isHidden = true
        button.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        addSubview(button)
        self.button = button
        
        let branch = UILabel()
        branch.translatesAutoresizingMaskIntoConstraints = false
        branch.font = .systemFont(ofSize: 14, weight: .bold)
        branch.textColor = .halo
        addSubview(branch)
        self.branch = branch
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.indicatorStyle = .white
        addSubview(scroll)
        self.scroll = scroll
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        title.centerYAnchor.constraint(equalTo: topAnchor, constant: 27).isActive = true
        
        button.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        button.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        
        branch.rightAnchor.constraint(equalTo: button.leftAnchor, constant: -14).isActive = true
        branch.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.bottomAnchor.constraint(equalTo: topAnchor, constant: 55).isActive = true
        
        loading.centerYAnchor.constraint(equalTo: branch.centerYAnchor).isActive = true
        loading.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        loading.widthAnchor.constraint(equalToConstant: 90).isActive = true
        loading.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func load(_ force: Bool) { if force || content == nil { refresh() } }
    
    private func update() {
        content?.removeFromSuperview()
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        self.content = content
        
        app.repository?.log { items in
            var top = self.scroll.topAnchor
            items.enumerated().forEach {
                let item = Item(items.count - $0.0, commit: $0.1, date: self.formatter.string(from: $0.1.author.date))
                content.addSubview(item)
                
                item.topAnchor.constraint(equalTo: top).isActive = true
                item.leftAnchor.constraint(equalTo: content.leftAnchor).isActive = true
                item.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true
                top = item.bottomAnchor
            }
            content.topAnchor.constraint(equalTo: self.scroll.topAnchor).isActive = true
            content.leftAnchor.constraint(equalTo: self.scroll.leftAnchor).isActive = true
            content.widthAnchor.constraint(equalTo: self.scroll.widthAnchor).isActive = true
            content.bottomAnchor.constraint(greaterThanOrEqualTo: top).isActive = true
            self.scroll.bottomAnchor.constraint(greaterThanOrEqualTo: top).isActive = true
            
            app.repository?.branch {
                self.branch.text = $0
                self.loading.isHidden = true
                self.button.isHidden = false
            }
        }
    }
    
    @objc private func refresh() {
        loading.isHidden = false
        button.isHidden = true
        branch.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.update() }
    }
}
