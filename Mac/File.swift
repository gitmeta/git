import Git
import AppKit

final class File: Window {
    private weak var slider: NSView!
    private weak var loading: NSImageView!
    private weak var middle: NSLayoutConstraint!
    private let url: URL
    
    init(_ url: URL) {
        self.url = url
        super.init(600, 400, style: .resizable)
        minSize = CGSize(width: 200, height: 200)
        name.stringValue = url.path
        
        let slider = NSView()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.wantsLayer = true
        slider.layer!.backgroundColor = NSColor.halo.withAlphaComponent(0.4).cgColor
        slider.isHidden = true
        contentView!.addSubview(slider)
        self.slider = slider
        
        let loading = NSImageView()
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.image = NSImage(named: "loading")
        loading.imageScaling = .scaleNone
        contentView!.addSubview(loading)
        self.loading = loading
        
        slider.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        slider.leftAnchor.constraint(greaterThanOrEqualTo: contentView!.leftAnchor, constant: 50).isActive = true
        slider.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -50).isActive = true
        slider.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        slider.widthAnchor.constraint(equalToConstant: 5).isActive = true
        middle = slider.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor)
        middle.priority = .init(300)
        middle.isActive = true
        
        loading.widthAnchor.constraint(equalToConstant: 100).isActive = true
        loading.heightAnchor.constraint(equalToConstant: 40).isActive = true
        loading.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        app.repository?.previous(url, error: { app.alert(.key("Alert.error"), message: $0.localizedDescription) }) { [weak self] in self?.content($0) }
    }
    
    override func mouseDragged(with: NSEvent) {
        if with.locationInWindow.y < frame.height - 50 {
            middle.constant += with.deltaX
        }
    }
    
    private func content(_ previous: (Date, Data)?) {
        loading.isHidden = true
        slider.isHidden = false
        
        let before = previous == nil ? message(.key("File.new")) : Display.make(url, data: previous!.1)
        before.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        before.setContentCompressionResistancePriority(.init(1), for: .vertical)
        before.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentView!.addSubview(before)
        
        let content = try? Data(contentsOf: url)
        let actual = content == nil ? message(.key("File.deleted")) : Display.make(url, data: content!)
        actual.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        actual.setContentCompressionResistancePriority(.init(1), for: .vertical)
        actual.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentView!.addSubview(actual)
        
        before.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
        before.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        before.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        before.rightAnchor.constraint(equalTo: slider.leftAnchor).isActive = true
        
        actual.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
        actual.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        actual.leftAnchor.constraint(equalTo: slider.rightAnchor).isActive = true
        actual.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        
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
    }
    
    private func message(_ string: String) -> Label {
        let label = Label()
        label.stringValue = string
        label.alignment = .center
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .halo
        return label
    }
    
    private func date(_ string: String) -> Label {
        let label = Label()
        label.wantsLayer = true
        label.stringValue = "    \(string)    "
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .black
        label.layer!.backgroundColor = NSColor.halo.cgColor
        label.layer!.cornerRadius = 12
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView!.addSubview(label)
        
        label.heightAnchor.constraint(equalToConstant: 24).isActive = true
        label.leftAnchor.constraint(greaterThanOrEqualTo: contentView!.leftAnchor, constant: 14).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -14).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -10).isActive = true
        return label
    }
}
