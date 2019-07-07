import Git
import UIKit

final class File: Pop {
    private weak var slider: UIView!
    private weak var middle: NSLayoutConstraint!
    private var delta = CGFloat(0)
    private let url: URL
    
    required init?(coder: NSCoder) { return nil }
    @discardableResult init(_ url: URL) {
        self.url = url
        super.init()
        name.text = url.lastPathComponent
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "timeline"), for: .normal)
        button.imageView!.contentMode = .center
        button.imageView!.clipsToBounds = true
        button.addTarget(self, action: #selector(timeline), for: .touchUpInside)
        addSubview(button)
        
        let slider = UIView()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isUserInteractionEnabled = false
        slider.backgroundColor = UIColor.halo.withAlphaComponent(0.3)
        slider.isHidden = true
        addSubview(slider)
        self.slider = slider
        
        button.bottomAnchor.constraint(equalTo: separator.topAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 70).isActive = true
        button.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        slider.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        slider.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 50).isActive = true
        slider.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -50).isActive = true
        slider.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        slider.widthAnchor.constraint(equalToConstant: 4).isActive = true
        middle = slider.centerXAnchor.constraint(equalTo: centerXAnchor)
        middle.priority = .init(300)
        middle.isActive = true
    }
    
    override func ready() {
        super.ready()
        app.repository?.previous(url, error: { app.alert(.key("Alert.error"), message: $0.localizedDescription) }) { [weak self] in self?.content($0) }
    }
    
    private func content(_ previous: (Date, Data)?) {
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pan(_:))))
        loading.isHidden = true
        slider.isHidden = false
        
        let before = previous == nil ? message(.key("File.new")) : Display.make(url, data: previous!.1)
        before.setContentCompressionResistancePriority(.init(0), for: .horizontal)
        addSubview(before)
        
        let content = try? Data(contentsOf: url)
        let actual = content == nil ? message(.key("File.deleted")) : Display.make(url, data: content!)
        actual.setContentCompressionResistancePriority(.init(0), for: .horizontal)
        addSubview(actual)

        before.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        before.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        before.rightAnchor.constraint(equalTo: slider.leftAnchor).isActive = true
        
        actual.topAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
        actual.leftAnchor.constraint(equalTo: slider.rightAnchor).isActive = true
        actual.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        if previous != nil && content != nil {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .medium
            let dateBefore = date(formatter.string(from: previous!.0))
            let dateActual = date(.key("File.now"))
            
            dateBefore.centerXAnchor.constraint(equalTo: before.centerXAnchor).isActive = true
            dateBefore.rightAnchor.constraint(lessThanOrEqualTo: slider.leftAnchor, constant: -5).isActive = true
            
            dateActual.centerXAnchor.constraint(equalTo: actual.centerXAnchor).isActive = true
            dateActual.leftAnchor.constraint(greaterThanOrEqualTo: slider.rightAnchor, constant: 5).isActive = true
        }
        
        if #available(iOS 11.0, *) {
            before.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
            actual.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            before.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            actual.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    private func message(_ string: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = string
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .halo
        return label
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
        
        label.heightAnchor.constraint(equalToConstant: 24).isActive = true
        label.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 14).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -14).isActive = true
        if #available(iOS 11.0, *) {
            label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        } else {
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        }
        return label
    }
    
    @objc private func pan(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            delta = middle.constant
        }
        middle.constant = delta + pan.translation(in: self).x
    }
    
    @objc private func timeline() {
        if Hub.session.purchase.contains(.timeline) {
            Timeline(url)
        } else {
            app.alert(.key("Alert.purchase"), message: .key("Timeline.purchase"))
        }
    }
}
