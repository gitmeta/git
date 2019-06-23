import Git
import AppKit

final class Reset: Window {
    init() {
        super.init(250, 250)
        border.isHidden = true
        
        let image = NSImageView()
        image.image = NSImage(named: "error")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        contentView!.addSubview(image)
        
        let label = Label()
        label.textColor = .white
        label.attributedStringValue = {
            $0.append(NSAttributedString(string: .local("Reset.title"), attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .bold)]))
            $0.append(NSAttributedString(string: .local("Reset.subtitle"), attributes: [.font: NSFont.systemFont(ofSize: 12, weight: .light)]))
            return $0
        } (NSMutableAttributedString())
        contentView!.addSubview(label)
        
        let confirm = Button.Yes(self, action: #selector(self.confirm))
        confirm.label.stringValue = .local("Reset.confirm")
        contentView!.addSubview(confirm)
        
        image.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
        image.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 60).isActive = true
        image.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        label.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        confirm.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        confirm.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -20).isActive = true
    }
    
    @objc private func confirm() {
        app.home.update(.loading)
        app.repository?.reset({
            app.refresh()
            app.alert(.local("Alert.error"), message: $0.localizedDescription)
        }) { [weak self] in
            app.alert(.local("Alert.success"), message: .local("Reset.success"))
            self?.close()
        }
    }
}
