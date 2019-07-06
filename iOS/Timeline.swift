import Git
import UIKit

final class Timeline: Pop, UIScrollViewDelegate {
    private final class Node: UIControl {
        private weak var circle: UIView!
        private weak var width: NSLayoutConstraint!
        private weak var height: NSLayoutConstraint!
        
        required init?(coder: NSCoder) { return nil }
        init(_ tag: Int) {
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
            
            circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            width = circle.widthAnchor.constraint(equalToConstant: 0)
            height = circle.heightAnchor.constraint(equalToConstant: 0)
            width.isActive = true
            height.isActive = true
            
            hover()
        }
        
        override var isSelected: Bool { didSet { hover() } }
        override var isHighlighted: Bool { didSet { hover() } }
        
        private func hover() {
            if isSelected || isHighlighted {
                circle.backgroundColor = .halo
                circle.layer.borderColor = UIColor.black.cgColor
                circle.layer.cornerRadius = 12
                width.constant = 24
                height.constant = 24
            } else {
                circle.backgroundColor = .black
                circle.layer.borderColor = UIColor.halo.cgColor
                circle.layer.cornerRadius = 6
                width.constant = 12
                height.constant = 12
            }
        }
    }
    
    private weak var content: UIView?
    private weak var scroll: UIScrollView!
    private weak var date: UILabel!
    private weak var track: UIView!
    private weak var left: NSLayoutConstraint!
    private weak var right: NSLayoutConstraint!
    private var items = [(String, Data)]()
    private let url: URL
    
    required init?(coder: NSCoder) { return nil }
    @discardableResult init(_ url: URL) {
        self.url = url
        super.init()
        name.attributedText = {
            $0.append(NSAttributedString(string: url.lastPathComponent, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold)]))
            $0.append(NSAttributedString(string: .key("Timeline.title"), attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .light)]))
            return $0
        } (NSMutableAttributedString())
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceHorizontal = true
        scroll.delegate = self
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
        track.backgroundColor = .halo
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
        right = track.rightAnchor.constraint(equalTo: content.rightAnchor)
        left = track.leftAnchor.constraint(equalTo: content.leftAnchor)
        right.isActive = true
        left.isActive = true
        
        if #available(iOS 11.0, *) {
            scroll.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotate), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    func scrollViewDidScroll(_: UIScrollView) {
        if scroll.isDragging {
            let center = scroll.contentOffset.x + bounds.midX
            if let closer = scroll.subviews.first!.subviews.compactMap({ $0 as? Node }).sorted(by: { abs($0.center.x - center) < abs($1.center.x - center) }).first {
                choose(closer, stop: true)
            }
        }
    }
    
    override func ready() {
        super.ready()
        app.repository?.timeline(url, error: { app.alert(.key("Alert.error"), message: $0.localizedDescription) }) { [weak self] in
            let format = DateFormatter()
            format.timeStyle = .short
            format.dateStyle = .medium
            self?.items = $0.map { (format.string(from: $0.0), $0.1) }
            if let last = self?.items.popLast() {
                self?.items.append((.key("Timeline.now"), last.1))
            }
            self?.render()
            self?.loading.isHidden = true
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
    
    private func render(_ stop: Bool = false) {
        var selected = items.count - 1
        scroll.subviews.first!.subviews.compactMap({ $0 as? Node }).forEach {
            if $0.isSelected {
                selected = $0.tag
            }
            $0.removeFromSuperview()
        }
        right.constant = -bounds.midX
        left.constant = bounds.midX
        var choose: Node!
        items.enumerated().forEach {
            let node = Node($0.0)
            node.addTarget(self, action: #selector(choose(_:stop:)), for: .touchUpInside)
            scroll.subviews.first!.addSubview(node)
            
            node.centerYAnchor.constraint(equalTo: track.centerYAnchor).isActive = true
            node.centerXAnchor.constraint(equalTo: scroll.subviews.first!.leftAnchor, constant: CGFloat($0.0 * 70) + bounds.midX).isActive = true
            
            if $0.0 == selected {
                choose = node
            }
            
            if $0.0 == items.count - 1 {
                track.rightAnchor.constraint(greaterThanOrEqualTo: node.centerXAnchor).isActive = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in self?.choose(choose, stop: stop) }
    }
    
    @objc private func rotate() { if left.constant != bounds.midX { render() } }
    
    @objc private func choose(_ button: Node, stop: Bool = false) {
        guard !button.isSelected else { return }
        scroll.subviews.first!.subviews.compactMap({ $0 as? Node }).forEach { $0.isSelected = false }
        button.isSelected = true
        date.text = "    " + items[button.tag].0 + "    "
        content(items[button.tag].1)
        if !stop {
            scroll.scrollRectToVisible(.init(x: CGFloat(button.tag * 70), y: 0, width: bounds.width, height: 1), animated: true)
        }
    }
}
