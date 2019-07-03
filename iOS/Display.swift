import Git
import UIKit

final class Display: UIView {
    private weak var slider: UIView!
    private weak var loading: UIImageView!
    private weak var separator: UIView!
    private weak var top: NSLayoutConstraint!
    private weak var middle: NSLayoutConstraint!
    private let formatter = DateFormatter()
    private var delta = CGFloat(0)
    
    required init?(coder: NSCoder) { return nil }
    @discardableResult init(_ url: URL) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        app.view.addSubview(self)
        
        let border = UIView()
        border.isUserInteractionEnabled = false
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        addSubview(border)
        
        let separator = UIView()
        separator.isUserInteractionEnabled = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .halo
        addSubview(separator)
        self.separator = separator
        
        let close = UIButton()
        close.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false
        close.setImage(UIImage(named: "close"), for: .normal)
        close.imageView!.contentMode = .center
        close.imageView!.clipsToBounds = true
        addSubview(close)
        
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textColor = .halo
        name.font = .bold(14)
        name.text = url.lastPathComponent
        addSubview(name)
        
        let slider = UIView()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isUserInteractionEnabled = false
        slider.backgroundColor = UIColor.halo.withAlphaComponent(0.3)
        slider.isHidden = true
        addSubview(slider)
        self.slider = slider
        
        let loading = UIImageView(image: UIImage(named: "loading"))
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.clipsToBounds = true
        loading.contentMode = .center
        addSubview(loading)
        self.loading = loading
        
        leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        widthAnchor.constraint(equalTo: app.view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: app.view.heightAnchor, constant: 3).isActive = true
        top = topAnchor.constraint(equalTo: app.view.topAnchor, constant: app.view.bounds.height)
        top.isActive = true
        
        border.topAnchor.constraint(equalTo: topAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 3).isActive = true
        
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        close.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        close.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        close.bottomAnchor.constraint(equalTo: separator.topAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        name.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -16).isActive = true
        name.leftAnchor.constraint(equalTo: close.rightAnchor, constant: -8).isActive = true
        
        slider.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        slider.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 50).isActive = true
        slider.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -50).isActive = true
        slider.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        slider.widthAnchor.constraint(equalToConstant: 4).isActive = true
        middle = slider.centerXAnchor.constraint(equalTo: centerXAnchor)
        middle.priority = .defaultLow
        middle.isActive = true
        
        loading.widthAnchor.constraint(equalToConstant: 100).isActive = true
        loading.heightAnchor.constraint(equalToConstant: 40).isActive = true
        loading.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            separator.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 53).isActive = true
        } else {
            separator.topAnchor.constraint(equalTo: topAnchor, constant: 53).isActive = true
        }
        
        app.view.layoutIfNeeded()
        top.constant = -3
        
        UIView.animate(withDuration: 0.5, animations: {
            app.view.layoutIfNeeded()
        }) { _ in
            do {
                let current = try Data(contentsOf: url)
                app.repository?.previous(url, error: { app.alert(.key("Alert.error"), message: $0.localizedDescription) }) { [weak self] in self?.content(url, current: current, previous: $0) }
            } catch {
                app.alert(.key("Alert.error"), message: error.localizedDescription)
            }
        }
    }
    
    private func content(_ url: URL, current: Data, previous: (Date, Data)?) {
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(_:))))
        loading.isHidden = true
        slider.isHidden = false
        
        var before: UIView!
        let actual: UIView
        
        switch url.pathExtension.lowercased() {
        case "png", "jpg", "jpeg", "gif", "bmp":
            before = UIImageView()
            actual = UIImageView()
        default:
            if let previous = previous {
                before = text(String(decoding: previous.1, as: UTF8.self))
            }
            actual = text(String(decoding: current, as: UTF8.self))
        }
        
        if previous == nil {
            before = UILabel()
            (before as! UILabel).text = .key("Display.new")
            (before as! UILabel).textAlignment = .center
            (before as! UILabel).font = .systemFont(ofSize: 14, weight: .medium)
            (before as! UILabel).textColor = .halo
        }
        
        before.translatesAutoresizingMaskIntoConstraints = false
        before.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(before)
        
        actual.translatesAutoresizingMaskIntoConstraints = false
        actual.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(actual)

        before.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        before.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        before.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        before.rightAnchor.constraint(equalTo: slider.leftAnchor).isActive = true
        
        actual.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        actual.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        actual.leftAnchor.constraint(equalTo: slider.rightAnchor).isActive = true
        actual.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        if previous != nil {
            let dateBefore = date(formatter.string(from: previous!.0))
            let dateActual = date(.key("Display.now"))
            
            dateBefore.centerXAnchor.constraint(equalTo: before.centerXAnchor).isActive = true
            dateBefore.rightAnchor.constraint(lessThanOrEqualTo: slider.leftAnchor, constant: -5).isActive = true
            
            dateActual.centerXAnchor.constraint(equalTo: actual.centerXAnchor).isActive = true
            dateActual.leftAnchor.constraint(greaterThanOrEqualTo: slider.rightAnchor, constant: 5).isActive = true
        }
        
        /*
         switch $0.pathExtension.lowercased() {
         case "md": return Md($0)
         case "pdf": return Pdf($0)
         case "png", "jpg", "jpeg", "gif", "bmp": return Image($0)
         default: return Editable($0)
         }
 */
    }
    
    
    private func date(_ string: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "    \(string)    "
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .black
        label.backgroundColor = .halo
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(label)
        
        label.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 8).isActive = true
        label.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return label
    }
    
    private func text(_ string: String) -> UITextView {
        let text = UITextView()
        text.text = string
        text.backgroundColor = .clear
        text.alwaysBounceVertical = true
        text.textColor = .white
        text.font = .light(14)
        text.textContainerInset = UIEdgeInsets(top: 40, left: 8, bottom: 20, right: 10)
        text.indicatorStyle = .white
        text.isEditable = false
        return text
    }
    
    @objc private func pan(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            delta = middle.constant
        }
        middle.constant = delta + pan.translation(in: self).x
    }
    
    @objc private func close() {
        top.constant = bounds.height
        UIView.animate(withDuration: 0.35, animations: {
            app.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
}
