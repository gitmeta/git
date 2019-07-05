import Git
import UIKit

final class Timeline: Pop {
    private final class Node: UIControl {
        let data: Data
        let date: String
        private weak var circle: UIView!
        
        required init?(coder: NSCoder) { return nil }
        init(_ tag: Int, data: Data, date: String) {
            self.data = data
            self.date = date
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            self.tag = tag
            
            let circle = UIView()
            circle.isUserInteractionEnabled = false
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.layer.cornerRadius = 8
            circle.layer.borderWidth = 1
            addSubview(circle)
            self.circle = circle
            
            widthAnchor.constraint(equalToConstant: 50).isActive = true
            heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            circle.widthAnchor.constraint(equalToConstant: 16).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 16).isActive = true
            circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            hover()
        }
        
        override var isSelected: Bool { didSet { hover() } }
        override var isHighlighted: Bool { didSet { hover() } }
        
        private func hover() {
            if isSelected || isHighlighted {
                circle.backgroundColor = .halo
                circle.layer.borderColor = UIColor.black.cgColor
            } else {
                circle.backgroundColor = .black
                circle.layer.borderColor = UIColor.halo.cgColor
            }
        }
    }
    
    private weak var content: UIView?
    private weak var scroll: UIScrollView!
    private weak var date: UILabel!
    private weak var track: UIView!
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
        scroll.alwaysBounceHorizontal = true
        addSubview(scroll)
        self.scroll = scroll
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        
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
        addSubview(date)
        self.date = date
        
        let track = UIView()
        track.translatesAutoresizingMaskIntoConstraints = false
        track.isUserInteractionEnabled = false
        track.backgroundColor = UIColor.halo.withAlphaComponent(0.3)
        content.addSubview(track)
        self.track = track
        
        scroll.heightAnchor.constraint(equalToConstant: 80).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        content.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true
        content.heightAnchor.constraint(equalTo: scroll.heightAnchor).isActive = true
        
        border.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 15).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        date.centerYAnchor.constraint(equalTo: border.centerYAnchor).isActive = true
        date.centerXAnchor.constraint(equalTo: border.centerXAnchor).isActive = true
        date.heightAnchor.constraint(equalToConstant: 24).isActive = true
        date.widthAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
        
        track.heightAnchor.constraint(equalToConstant: 2).isActive = true
        track.topAnchor.constraint(equalTo: content.topAnchor, constant: 55).isActive = true
        track.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -min(bounds.width, bounds.height) / 2).isActive = true
        track.leftAnchor.constraint(equalTo: content.leftAnchor, constant: min(bounds.width, bounds.height) / 2).isActive = true
        
        if #available(iOS 11.0, *) {
            scroll.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    override func ready() {
        super.ready()
        app.repository?.timeline(url, error: { app.alert(.key("Alert.error"), message: $0.localizedDescription) }) { [weak self] items in
            guard let self = self else { return }
            items.enumerated().forEach {
                let button = Node($0.0, data: $0.1.1, date: $0.0 == items.count - 1 ? .key("Timeline.now") : self.formatter.string(from: $0.1.0))
                button.addTarget(self, action: #selector(self.choose(_:)), for: .touchUpInside)
                self.scroll.subviews.first!.addSubview(button)
                
                button.centerYAnchor.constraint(equalTo: self.track.centerYAnchor).isActive = true
                button.centerXAnchor.constraint(equalTo: self.scroll.subviews.first!.leftAnchor, constant: CGFloat($0.0 * 70) + (min(self.bounds.width, self.bounds.height) / 2)).isActive = true
                self.track.rightAnchor.constraint(greaterThanOrEqualTo: button.centerXAnchor).isActive = true
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.loading.isHidden = true
                self.choose(self.scroll.subviews.first!.subviews.last as! Node)
            }
        }
    }
    
    private func content(_ data: Data) {
        self.content?.removeFromSuperview()
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(content, at: 0)
        self.content = content
        
        content.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: date.centerYAnchor).isActive = true
    }
    
    @objc private func choose(_ button: Node) {
        scroll.subviews.first!.subviews.compactMap({ $0 as? Node }).forEach { $0.isSelected = false }
        button.isSelected = true
        date.text = "    " + button.date + "    "
        content(button.data)
        scroll.scrollRectToVisible(.init(x: CGFloat(button.tag * 70) - bounds.midX + (min(bounds.width, bounds.height) / 2), y: 0, width: bounds.width, height: 1), animated: true)
    }
}
