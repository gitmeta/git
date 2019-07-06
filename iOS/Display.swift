import UIKit
import PDFKit

final class Display {
    class func make(_ url: URL, data: Data) -> UIView {
        switch url.pathExtension.lowercased() {
        case "png", "jpg", "jpeg", "gif", "bmp": return image(data)
        case "pdf": return pdf(data)
        default: return text(data)
        }
    }
    
    private class func text(_ data: Data) -> UITextView {
        let text = UITextView()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = String(decoding: data, as: UTF8.self)
        text.backgroundColor = .clear
        text.alwaysBounceVertical = true
        text.textColor = .white
        text.font = .light(14)
        text.textContainerInset = UIEdgeInsets(top: 20, left: 12, bottom: 40, right: 12)
        text.indicatorStyle = .white
        text.isEditable = false
        return text
    }
    
    private class func image(_ data: Data) -> UIImageView {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.image = UIImage(data: data)
        return image
    }
    
    private class func pdf(_ data: Data) -> UIView {
        let view: UIView
        if #available(iOS 11.0, *) {
            view = PDFView()
            view.backgroundColor = .clear
            (view as! PDFView).document = PDFDocument(data: data)
        } else {
            view = UIView()
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
