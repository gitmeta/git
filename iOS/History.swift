import Git
import UIKit

final class History: UIView {
    private final class Item: UIView {
        init(_ index: Int, commit: Commit) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isUserInteractionEnabled = false
            
            let number = UILabel()
            number.text = String(index)
            number.translatesAutoresizingMaskIntoConstraints = false
            number.font = .systemFont(ofSize: 16, weight: .bold)
            number.textColor = .halo
            addSubview(number)
            
            let author = UILabel()
            author.translatesAutoresizingMaskIntoConstraints = false
            author.text = commit.author.name
            author.textColor = .halo
            author.font = .systemFont(ofSize: 16, weight: .medium)
            addSubview(author)
            
            let border = UIView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.isUserInteractionEnabled = false
            border.backgroundColor = UIColor.halo.withAlphaComponent(0.4)
            addSubview(border)
            
            let date = UILabel()
            date.translatesAutoresizingMaskIntoConstraints = false
            date.text = {
                $0.timeStyle = .short
                $0.dateStyle = Calendar.current.dateComponents([.hour], from: $1, to: Date()).hour! > 12 ? .medium : .none
                return $0.string(from: $1)
            } (DateFormatter(), commit.author.date)
            date.textColor = .halo
            date.font = .systemFont(ofSize: 12, weight: .light)
            addSubview(date)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = commit.message
            label.textColor = .white
            label.font = .light(14)
            label.numberOfLines = 0
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addSubview(label)
            
            number.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            number.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
            
            author.bottomAnchor.constraint(equalTo: number.bottomAnchor).isActive = true
            author.leftAnchor.constraint(equalTo: number.rightAnchor, constant: 6).isActive = true
            
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            date.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            date.topAnchor.constraint(equalTo: number.bottomAnchor, constant: 5).isActive = true
            
            label.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 16).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -16).isActive = true
            label.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -20).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private weak var content: UIView?
    private weak var scroll: UIScrollView!
    private weak var loading: UIImageView!
    private weak var branch: UILabel!
    private weak var button: UIButton!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
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
        title.text = .local("History.title")
        addSubview(title)
        
        let border = UIView()
        border.isUserInteractionEnabled = true
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        addSubview(border)
        
        let button = Button.Yes(.local("History.refresh"))
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
        
        button.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
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
    
    required init?(coder: NSCoder) { return nil }
    func load() { if content == nil { refresh() } }
    
    private func update() {
        content?.removeFromSuperview()
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        self.content = content
        
        app.repository?.log { items in
            var top = self.scroll.topAnchor
            items.enumerated().forEach {
                let item = Item(items.count - $0.0, commit: $0.1)
                content.addSubview(item)
                
                item.topAnchor.constraint(equalTo: top, constant: 10).isActive = true
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
