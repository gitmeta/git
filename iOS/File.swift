import Git
import UIKit
import PDFKit

final class File: Pop {
    private weak var slider: UIView!
    private weak var middle: NSLayoutConstraint!
    private var delta = CGFloat(0)
    private let url: URL
    private let formatter = DateFormatter()
    
    required init?(coder: NSCoder) { return nil }
    @discardableResult init(_ url: URL) {
        self.url = url
        super.init()
        name.text = url.lastPathComponent
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        let button = Button.Yes(.key("File.timeline"))
        button.addTarget(self, action: #selector(timeline), for: .touchUpInside)
        addSubview(button)
        
        let slider = UIView()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isUserInteractionEnabled = false
        slider.backgroundColor = UIColor.halo.withAlphaComponent(0.3)
        slider.isHidden = true
        addSubview(slider)
        self.slider = slider
        
        button.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        button.centerYAnchor.constraint(equalTo: close.centerYAnchor).isActive = true
        
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
        do {
            let current = try Data(contentsOf: url)
            app.repository?.previous(url, error: { app.alert(.key("Alert.error"), message: $0.localizedDescription) }) { [weak self] in
                guard let url = self?.url else { return }
                self?.content(url, current: current, previous: $0) }
        } catch {
            app.alert(.key("Alert.error"), message: error.localizedDescription)
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
            if let previous = previous {
                before = image(previous.1)
            }
            actual = image(current)
        case "pdf":
            if let previous = previous {
                before = pdf(previous.1)
            }
            actual = pdf(current)
        default:
            if let previous = previous {
                before = text(String(decoding: previous.1, as: UTF8.self))
            }
            actual = text(String(decoding: current, as: UTF8.self))
        }
        
        if previous == nil {
            before = UILabel()
            (before as! UILabel).text = .key("File.new")
            (before as! UILabel).textAlignment = .center
            (before as! UILabel).font = .systemFont(ofSize: 14, weight: .medium)
            (before as! UILabel).textColor = .halo
        }
        
        before.translatesAutoresizingMaskIntoConstraints = false
        before.setContentCompressionResistancePriority(.init(0), for: .horizontal)
        addSubview(before)
        
        actual.translatesAutoresizingMaskIntoConstraints = false
        actual.setContentCompressionResistancePriority(.init(0), for: .horizontal)
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
            let dateActual = date(.key("File.now"))
            
            dateBefore.centerXAnchor.constraint(equalTo: before.centerXAnchor).isActive = true
            dateBefore.rightAnchor.constraint(lessThanOrEqualTo: slider.leftAnchor, constant: -5).isActive = true
            
            dateActual.centerXAnchor.constraint(equalTo: actual.centerXAnchor).isActive = true
            dateActual.leftAnchor.constraint(greaterThanOrEqualTo: slider.rightAnchor, constant: 5).isActive = true
        }
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
        label.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 8).isActive = true
        label.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 14).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -14).isActive = true
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
    
    private func image(_ data: Data) -> UIImageView {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.image = UIImage(data: data)
        return image
    }
    
    private func pdf(_ data: Data) -> UIView {
        if #available(iOS 11.0, *) {
            let pdf = PDFView()
            pdf.backgroundColor = .clear
            pdf.document = PDFDocument(data: data)
            return pdf
        }
        return UIView()
    }
    
    @objc private func pan(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            delta = middle.constant
        }
        middle.constant = delta + pan.translation(in: self).x
    }
    
    @objc private func timeline() {
        if true || Hub.session.purchase.contains(.timeline) {
            Timeline(url)
        } else {
            app.alert(.key("Alert.purchase"), message: .key("Timeline.purchase"))
        }
    }
}
