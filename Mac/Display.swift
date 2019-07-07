import AppKit
import Quartz

final class Display {
    class func make(_ url: URL, data: Data) -> NSView {
        switch url.pathExtension.lowercased() {
        case "png", "jpg", "jpeg", "gif", "bmp": return image(data)
        case "pdf": return pdf(data)
        default: return text(data)
        }
    }
    
    private class func text(_ data: Data) -> Scroll {
        let text = NSTextView()
        text.drawsBackground = false
        text.isRichText = false
        text.font = .light(16)
        text.textColor = .white
        text.textContainerInset = NSSize(width: 12, height: 20)
        text.isEditable = false
        text.string = String(decoding: data, as: UTF8.self)
        text.isVerticallyResizable = true
        text.isHorizontallyResizable = true
        
        let scroll = Scroll()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.documentView = text
        text.textContainer!.widthTracksTextView = true
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
