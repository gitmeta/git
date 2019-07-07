import Git
import AppKit

final class Timeline: Window {
    private weak var loading: NSImageView!
    let url: URL
    
    init(_ url: URL) {
        self.url = url
        super.init(500, 500, style: .resizable)
        minSize = CGSize(width: 200, height: 200)
        name.attributedStringValue = {
            $0.append(NSAttributedString(string: .key("Timeline.title") + " ", attributes: [.font: NSFont.systemFont(ofSize: 12, weight: .bold)]))
            $0.append(NSAttributedString(string: url.path, attributes: [.font: NSFont.systemFont(ofSize: 12, weight: .light)]))
            return $0
        } (NSMutableAttributedString())
        
        let loading = NSImageView()
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.image = NSImage(named: "loading")
        loading.imageScaling = .scaleNone
        contentView!.addSubview(loading)
        self.loading = loading
        
        loading.widthAnchor.constraint(equalToConstant: 100).isActive = true
        loading.heightAnchor.constraint(equalToConstant: 40).isActive = true
        loading.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
    }
}
