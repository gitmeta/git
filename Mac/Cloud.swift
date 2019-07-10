import Git
import AppKit

final class Cloud: Window, NSTextFieldDelegate {
    private weak var field: NSTextField!
    private weak var loading: NSImageView!
    private weak var button: Button.Yes!
    
    init() {
        super.init(500, 180)
        name.stringValue = .key("Cloud.title")
        
        let label = Label(.key("Cloud.field"))
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .halo
        contentView!.addSubview(label)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = NSColor.halo.cgColor
        contentView!.addSubview(border)
        
        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isBezeled = false
        field.font = .systemFont(ofSize: 15, weight: .regular)
        field.focusRingType = .none
        field.drawsBackground = false
        field.textColor = .white
        field.maximumNumberOfLines = 1
        field.lineBreakMode = .byTruncatingHead
        field.delegate = self
        (fieldEditor(true, for: field) as? NSTextView)?.insertionPointColor = .halo
        if #available(OSX 10.12.2, *) {
            field.isAutomaticTextCompletionEnabled = false
        }
        contentView!.addSubview(field)
        self.field = field
        
        let loading = NSImageView()
        loading.image = NSImage(named: "loading")
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.imageScaling = .scaleNone
        loading.isHidden = true
        contentView!.addSubview(loading)
        self.loading = loading
        
        let button = Button.Yes(self, action: #selector(make))
        button.label.stringValue = app.repository == nil ? .key("Cloud.clone.button") : .key("Cloud.synch.button")
        contentView!.addSubview(button)
        self.button = button
        
        label.topAnchor.constraint(equalTo: self.border.bottomAnchor, constant: 24).isActive = true
        label.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 20).isActive = true
        
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 2).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 20).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -20).isActive = true
        
        field.topAnchor.constraint(equalTo: self.border.bottomAnchor, constant: 25).isActive = true
        field.heightAnchor.constraint(equalToConstant: 30).isActive = true
        field.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 80).isActive = true
        field.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -34).isActive = true
        
        loading.centerYAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -31).isActive = true
        loading.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        button.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -20).isActive = true
        button.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        field.refusesFirstResponder = app.repository != nil
        app.repository?.remote { [weak self] in self?.field.stringValue = $0 }
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy: Selector) -> Bool {
        if doCommandBy == #selector(NSResponder.insertNewline(_:)) {
            makeFirstResponder(nil)
            return true
        } else if doCommandBy == #selector(NSResponder.cancelOperation(_:)) {
            makeFirstResponder(nil)
            return true
        }
        return false
    }
    
    func controlTextDidEndEditing(_: Notification) { app.repository?.remote(field.stringValue) }
    
    private func ready() {
        button.isHidden = false
        loading.isHidden = true
        field.isEditable = true
    }
    
    @objc private func make() {
        makeFirstResponder(nil)
        button.isHidden = true
        loading.isHidden = false
        field.isEditable = false
        if app.repository == nil {
            if let name = field.stringValue.components(separatedBy: "/").last?.replacingOccurrences(of: ".git", with: ""),
                !name.isEmpty,
                !FileManager.default.fileExists(atPath: Hub.session.url.appendingPathComponent(name).path) {
                Hub.clone(field.stringValue, local: Hub.session.url.appendingPathComponent(name), error: { [weak self] in
                    app.alert(.key("Alert.error"), message: $0.localizedDescription)
                    self?.ready()
                }) { [weak self] in
                    app.alert(.key("Alert.success"), message: .key("Cloud.clone.success"))
                    self?.close()
                    app.browsed(Hub.session.url.appendingPathComponent(name))
                }
            } else {
                app.alert(.key("Alert.error"), message: .key("Cloud.clone.name"))
                ready()
            }
        } else {
            app.repository!.pull({ [weak self] in
                app.alert(.key("Alert.error"), message: $0.localizedDescription)
                self?.ready()
            }) { [weak self] in
                app.repository!.push({ [weak self] in
                    app.alert(.key("Alert.error"), message: $0.localizedDescription)
                    self?.ready()
                }) { [weak self] in
                    app.alert(.key("Alert.success"), message: .key("Cloud.synch.success"))
                    self?.ready()
                }
            }
        }
    }
}
