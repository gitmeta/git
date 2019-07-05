import Git
import UIKit

final class Timeline: Pop {
    private weak var scroll: UIScrollView!
    private weak var date: UILabel!
    private let url: URL
    private let formatter = DateFormatter()
    
    required init?(coder: NSCoder) { return nil }
    @discardableResult init(_ url: URL) {
        self.url = url
        super.init()
        name.text = .key("Timeline.title")
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scroll)
        self.scroll = scroll
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        border.isUserInteractionEnabled = false
        addSubview(border)
        
        let date = UILabel()
        date.translatesAutoresizingMaskIntoConstraints = false
        date.backgroundColor = .halo
        date.layer.cornerRadius = 12
        date.clipsToBounds = true
        date.textColor = .black
        date.font = .systemFont(ofSize: 12, weight: .regular)
        date.textAlignment = .center
        addSubview(date)
        self.date = date
        
        scroll.heightAnchor.constraint(equalToConstant: 80).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        border.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 15).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        date.centerYAnchor.constraint(equalTo: border.centerYAnchor).isActive = true
        date.centerXAnchor.constraint(equalTo: border.centerXAnchor).isActive = true
        date.heightAnchor.constraint(equalToConstant: 24).isActive = true
        date.widthAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
        
        if #available(iOS 11.0, *) {
            scroll.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    override func ready() {
        
    }
}
