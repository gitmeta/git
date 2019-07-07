import Git
import AppKit

final class File: Window {
    private weak var slider: NSView!
    private weak var loading: NSImageView!
    private weak var middle: NSLayoutConstraint!
    let url: URL
    
    init(_ url: URL) {
        self.url = url
        super.init(700, 500, style: .resizable)
        minSize = CGSize(width: 250, height: 250)
        name.stringValue = url.path
        
        let button = Button.Image(self, action: #selector(timeline))
        button.image.image = NSImage(named: "timeline")
        contentView!.addSubview(button)
        
        let slider = NSView()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.wantsLayer = true
        slider.layer!.backgroundColor = NSColor.halo.withAlphaComponent(0.25).cgColor
        slider.isHidden = true
        contentView!.addSubview(slider)
        self.slider = slider
        
        let loading = NSImageView()
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.image = NSImage(named: "loading")
        loading.imageScaling = .scaleNone
        contentView!.addSubview(loading)
        self.loading = loading
        
        name.rightAnchor.constraint(lessThanOrEqualTo: button.leftAnchor).isActive = true
        
        button.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 54).isActive = true
        button.centerYAnchor.constraint(equalTo: name.centerYAnchor).isActive = true
        
        slider.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        slider.leftAnchor.constraint(greaterThanOrEqualTo: contentView!.leftAnchor, constant: 50).isActive = true
        slider.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -50).isActive = true
        slider.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        slider.widthAnchor.constraint(equalToConstant: 18).isActive = true
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
        
        let before = previous == nil ? none() : Display.make(url, data: previous!.1)
        before.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        before.setContentCompressionResistancePriority(.init(1), for: .vertical)
        before.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentView!.addSubview(before)
        
        let content = try? Data(contentsOf: url)
        let actual = content == nil ? none() : Display.make(url, data: content!)
        actual.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        actual.setContentCompressionResistancePriority(.init(1), for: .vertical)
        actual.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentView!.addSubview(actual)
        
        before.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        before.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        before.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        before.rightAnchor.constraint(equalTo: slider.leftAnchor).isActive = true
        
        actual.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
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
    
    private func none() -> NSView {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer!.backgroundColor = NSColor.halo.withAlphaComponent(0.25).cgColor
        return view
    }
    
    private func date(_ string: String) -> NSView {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer!.backgroundColor = NSColor.halo.cgColor
        view.layer!.cornerRadius = 12
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView!.addSubview(view)
        
        let label = Label()
        label.stringValue = string
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.maximumNumberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        view.addSubview(label)
        
        view.heightAnchor.constraint(equalToConstant: 24).isActive = true
        view.leftAnchor.constraint(greaterThanOrEqualTo: contentView!.leftAnchor, constant: 14).isActive = true
        view.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -14).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -10).isActive = true
        view.leftAnchor.constraint(equalTo: label.leftAnchor, constant: -14).isActive = true
        view.rightAnchor.constraint(equalTo: label.rightAnchor, constant: 14).isActive = true
        
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }
    
    @objc private func timeline() {
        if true || Hub.session.purchase.contains(.timeline) {
            if let timeline = app.windows.compactMap({ $0 as? Timeline }).first(where: { $0.url == url }) {
                timeline.orderFront(nil)
            } else {
                Timeline(url).makeKeyAndOrderFront(nil)
            }
        } else {
            app.alert(.key("Alert.purchase"), message: .key("Timeline.purchase"))
        }
    }
}
