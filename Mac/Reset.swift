import Git
import AppKit

class Reset: NSWindow {
    init() {
        super.init(contentRect: NSRect(
            x: app.home.frame.minX + 50, y: app.home.frame.maxY - 300, width: 250, height: 250),
                   styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        isReleasedWhenClosed = false
        
        let image = NSImageView()
        image.image = NSImage(named: "error")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        contentView!.addSubview(image)
        
        let label = Label()
        label.attributedStringValue = {
            $0.append(NSAttributedString(string: .local("Reset.title"), attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .bold),
                                                                                     .foregroundColor: NSColor.white]))
            $0.append(NSAttributedString(string: .local("Reset.subtitle"), attributes: [.font: NSFont.systemFont(ofSize: 12, weight: .light),
                                                                                        .foregroundColor: NSColor(white: 1, alpha: 0.7)]))
            return $0
        } (NSMutableAttributedString())
        contentView!.addSubview(label)
        
        let confirm = Button.Text(self, action: #selector(self.confirm))
        confirm.label.textColor = .black
        confirm.label.font = .systemFont(ofSize: 11, weight: .medium)
        confirm.label.stringValue = .local("Reset.confirm")
        confirm.wantsLayer = true
        confirm.layer!.backgroundColor = NSColor.halo.cgColor
        confirm.layer!.cornerRadius = 4
        contentView!.addSubview(confirm)
        
        image.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
        image.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true
        image.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        label.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        confirm.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        confirm.widthAnchor.constraint(equalToConstant: 62).isActive = true
        confirm.heightAnchor.constraint(equalToConstant: 22).isActive = true
        confirm.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -20).isActive = true
    }
    
    @objc private func confirm() {
        app.home.update(.loading)
        app.repository?.reset({
            app.refresh()
            app.alert.error($0.localizedDescription)
        }) { [weak self] in
            app.alert.update(.local("Reset.success"))
            self?.close()
        }
    }
}
