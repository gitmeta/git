import Git
import AppKit
import Quartz

final class Display: Window {
    private weak var slider: NSView!
    private weak var loading: NSImageView!
    private weak var middle: NSLayoutConstraint!
    private let formatter = DateFormatter()
    
    init(_ url: URL) {
        super.init(600, 400, style: .resizable)
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
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
        
        do {
            let current = try Data(contentsOf: url)
            app.repository?.previous(url, error: { app.alert(.key("Alert.error"), message: $0.localizedDescription) }) { [weak self] in self?.content(url, current: current, previous: $0) }
        } catch {
            app.alert(.key("Alert.error"), message: error.localizedDescription)
        }
    }
    
    override func mouseDragged(with: NSEvent) {
        if with.locationInWindow.y < frame.height - 50 {
            middle.constant += with.deltaX
        }
    }
    
    private func content(_ url: URL, current: Data, previous: (Date, Data)?) {
        loading.isHidden = true
        slider.isHidden = false
        
        var before: NSView!
        let actual: NSView
        
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
            before = Label()
            (before as! Label).stringValue = .key("File.new")
            (before as! Label).alignment = .center
            (before as! Label).font = .systemFont(ofSize: 14, weight: .medium)
            (before as! Label).textColor = .halo
        }
        
        before.translatesAutoresizingMaskIntoConstraints = false
        before.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        before.setContentCompressionResistancePriority(.init(1), for: .vertical)
        before.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentView!.addSubview(before)
        
        actual.translatesAutoresizingMaskIntoConstraints = false
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
        
        if previous != nil {
            let dateBefore = date(formatter.string(from: previous!.0))
            let dateActual = date(.key("File.now"))
            
            dateBefore.centerXAnchor.constraint(equalTo: before.centerXAnchor).isActive = true
            dateBefore.rightAnchor.constraint(lessThanOrEqualTo: slider.leftAnchor, constant: -5).isActive = true
            
            dateActual.centerXAnchor.constraint(equalTo: actual.centerXAnchor).isActive = true
            dateActual.leftAnchor.constraint(greaterThanOrEqualTo: slider.rightAnchor, constant: 5).isActive = true
        }
    }
    
    private func date(_ string: String) -> Label {
        let label = Label()
        label.wantsLayer = true
        label.stringValue = "    \(string)    "
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .black
        label.layer!.backgroundColor = NSColor.halo.cgColor
        label.layer!.cornerRadius = 9
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView!.addSubview(label)
        
        label.heightAnchor.constraint(equalToConstant: 18).isActive = true
        label.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 8).isActive = true
        label.leftAnchor.constraint(greaterThanOrEqualTo: contentView!.leftAnchor, constant: 14).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -14).isActive = true
        return label
    }
    
    private func text(_ string: String) -> NSView {
        let text = NSTextView()
        text.drawsBackground = false
        text.isRichText = false
        text.font = .light(16)
        text.textColor = .white
        text.textContainerInset = NSSize(width: 12, height: 20)
        text.isEditable = false
        text.string = string
        text.isVerticallyResizable = true
        text.isHorizontallyResizable = true
        
        let scroll = Scroll()
        scroll.documentView = text
        text.textContainer!.widthTracksTextView = true
        return scroll
    }
    
    private func image(_ data: Data) -> NSImageView {
        let image = NSImageView()
        image.imageScaling = .scaleProportionallyDown
        image.image = NSImage(data: data)
        return image
    }
    
    private func pdf(_ data: Data) -> PDFView {
        let pdf = PDFView()
        pdf.backgroundColor = .clear
        pdf.document = PDFDocument(data: data)
        return pdf
    }
}
