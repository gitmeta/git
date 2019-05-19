import Git
import UIKit

class Log: Sheet {
    private class Item: UIView {
        private weak var label: UILabel!
        
        init(_ index: Int, commit: Git.Commit) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            isUserInteractionEnabled = false
            
            let circle = UIView()
            circle.isUserInteractionEnabled = false
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.backgroundColor = .halo
            circle.layer.cornerRadius = 17
            addSubview(circle)
            
            let number = UILabel()
            number.translatesAutoresizingMaskIntoConstraints = false
            number.text = String(index)
            number.textAlignment = .center
            number.font = .systemFont(ofSize: 12, weight: .medium)
            number.textColor = .black
            addSubview(number)
            
            let author = UILabel()
            author.translatesAutoresizingMaskIntoConstraints = false
            author.text = commit.author.name
            author.textColor = UIColor(white: 1, alpha: 0.5)
            author.font = .systemFont(ofSize: 16, weight: .medium)
            addSubview(author)
            
            let date = UILabel()
            date.translatesAutoresizingMaskIntoConstraints = false
            date.text = {
                $0.timeStyle = .short
                $0.dateStyle = Calendar.current.dateComponents([.hour], from: $1, to: Date()).hour! > 12 ? .long : .none
                return $0.string(from: $1)
            } (DateFormatter(), commit.author.date)
            date.textColor = UIColor(white: 1, alpha: 0.5)
            date.font = .systemFont(ofSize: 12, weight: .light)
            addSubview(date)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = commit.message
            label.textColor = .white
            label.font = .systemFont(ofSize: 16, weight: .light)
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.numberOfLines = 0
            addSubview(label)
            self.label = label
            
            circle.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            circle.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
            circle.widthAnchor.constraint(equalToConstant: 34).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 34).isActive = true
            
            number.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
            number.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
            
            author.bottomAnchor.constraint(equalTo: date.topAnchor).isActive = true
            author.leftAnchor.constraint(equalTo: date.leftAnchor).isActive = true
            
            date.bottomAnchor.constraint(equalTo: circle.bottomAnchor).isActive = true
            date.leftAnchor.constraint(equalTo: circle.rightAnchor, constant: 7).isActive = true
            
            label.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 30).isActive = true
            label.leftAnchor.constraint(equalTo: circle.leftAnchor, constant: 6).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    @discardableResult override init() {
        super.init()
        let cancel = UIButton()
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        cancel.setImage(#imageLiteral(resourceName: "cancelOff.pdf"), for: .normal)
        cancel.setImage(#imageLiteral(resourceName: "cancelOn.pdf"), for: .highlighted)
        cancel.imageView!.clipsToBounds = true
        cancel.imageView!.contentMode = .center
        addSubview(cancel)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = .local("Log.title")
        title.textColor = .halo
        title.font = .systemFont(ofSize: 14, weight: .bold)
        addSubview(title)
        
        let border = UIView()
        border.isUserInteractionEnabled = false
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = UIColor(white: 1, alpha: 0.1)
        addSubview(border)
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.indicatorStyle = .white
        scroll.alwaysBounceVertical = true
        addSubview(scroll)
        
        cancel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        title.centerYAnchor.constraint(equalTo: cancel.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        
        border.topAnchor.constraint(equalTo: cancel.bottomAnchor, constant: 5).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor, constant: -2).isActive = true
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            cancel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        } else {
            cancel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        }
        
        App.repository?.log { items in
            var top = scroll.topAnchor
            items.enumerated().forEach {
                let item = Item(items.count - $0.0, commit: $0.1)
                scroll.addSubview(item)
                
                item.topAnchor.constraint(equalTo: top, constant: 10).isActive = true
                item.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
                item.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
                top = item.bottomAnchor
            }
            scroll.bottomAnchor.constraint(greaterThanOrEqualTo: top, constant: 30).isActive = true
        }
    }
    
    required init?(coder: NSCoder) { return nil }
}
