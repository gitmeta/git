import AppKit
import Quartz

final class Display {
    private final class Text: NSTextView {
        private weak var height: NSLayoutConstraint!
        
        required init?(coder: NSCoder) { return nil }
        init() {
            let storage = NSTextStorage()
            super.init(frame: .zero, textContainer: {
                storage.addLayoutManager($1)
                $1.addTextContainer($0)
                $0.lineBreakMode = .byCharWrapping
                return $0
            } (NSTextContainer(), NSLayoutManager()) )
            translatesAutoresizingMaskIntoConstraints = false
            drawsBackground = false
            isRichText = false
            font = .light(16)
            textColor = .white
            isEditable = false
            textContainerInset = NSSize(width: 10, height: 10)
            height = heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
            height.isActive = true
        }
        
        override func resize(withOldSuperviewSize: NSSize) {
            super.resize(withOldSuperviewSize: withOldSuperviewSize)
            adjust()
        }
        
        override func viewDidEndLiveResize() {
            super.viewDidEndLiveResize()
            adjust()
        }
        
        private func adjust() {
            textContainer!.size.width = superview!.superview!.frame.width - (textContainerInset.width * 2)
            layoutManager!.ensureLayout(for: textContainer!)
            height.constant = layoutManager!.usedRect(for: textContainer!).size.height + (textContainerInset.height * 2) + 30
        }
    }
    
    class func make(_ url: URL, data: Data) -> NSView {
        switch url.pathExtension.lowercased() {
        case "png", "jpg", "jpeg", "gif", "bmp": return image(data)
        case "pdf": return pdf(data)
        default: return text(data)
        }
    }
    
    private class func text(_ data: Data) -> Scroll {
        let text = Text()
        text.string = String(decoding: data, as: UTF8.self)
        
        let scroll = Scroll()
        scroll.documentView = text
        
        text.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        text.heightAnchor.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        
        return scroll
    }
    
    private class func image(_ data: Data) -> NSImageView {
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleProportionallyDown
        image.image = NSImage(data: data)
        return image
    }
    
    private class func pdf(_ data: Data) -> PDFView {
        let pdf = PDFView()
        pdf.translatesAutoresizingMaskIntoConstraints = false
        pdf.backgroundColor = .clear
        pdf.document = PDFDocument(data: data)
        return pdf
    }
}
