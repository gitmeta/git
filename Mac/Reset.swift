import Git
import AppKit

class Reset: Sheet {
    @discardableResult override init() {
        super.init()
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = NSImage(named: "error")
        image.imageScaling = .scaleNone
        addSubview(image)
        
        let label = Label()
        label.attributedStringValue = {
            $0.append(NSAttributedString(string: .local("Reset.title"), attributes: [.font: NSFont.systemFont(ofSize: 16, weight: .bold),
                                                                                     .foregroundColor: NSColor.white]))
            $0.append(NSAttributedString(string: .local("Reset.subtitle"), attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .light),
                                                                                        .foregroundColor: NSColor(white: 1, alpha: 0.6)]))
            return $0
        } (NSMutableAttributedString())
        addSubview(label)
        
        let confirm = Button.Text(self, action: #selector(self.confirm))
        confirm.label.textColor = .black
        confirm.label.font = .systemFont(ofSize: 14, weight: .medium)
        confirm.label.stringValue = .local("Reset.confirm")
        confirm.wantsLayer = true
        confirm.layer!.backgroundColor = NSColor.halo.cgColor
        confirm.layer!.cornerRadius = 6
        confirm.width.constant = 70
        confirm.height.constant = 28
        addSubview(confirm)
        
        let cancel = Button.Text(self, action: #selector(close))
        cancel.label.textColor = .white
        cancel.label.font = .systemFont(ofSize: 14, weight: .medium)
        cancel.label.stringValue = .local("Reset.cancel")
        cancel.width.constant = 70
        cancel.height.constant = 28
        addSubview(cancel)
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        
        confirm.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        confirm.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -10).isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cancel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc private func confirm() {
        close()
        App.repository?.reset({
            App.window.alert.error($0.localizedDescription)
        }) {
            App.window.alert.update(.local("Reset.success"))
            App.window.refresh()
        }
    }
}
