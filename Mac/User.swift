import AppKit

class User: Sheet, NSTextFieldDelegate {
    private weak var name: NSTextField!
    private weak var email: NSTextField!
    
    @discardableResult override init() {
        super.init()
        let title = Label(.local("User.title"))
        addSubview(title)
        
        let name = NSTextField()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.isBezeled = false
        name.font = .light(20)
        name.focusRingType = .none
        name.drawsBackground = false
        name.textColor = .white
        name.maximumNumberOfLines = 1
        name.lineBreakMode = .byTruncatingHead
        name.delegate = self
        addSubview(name)
        (name.window?.fieldEditor(true, for: name) as! NSTextView).insertionPointColor = .halo
        self.name = name
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = NSColor.white.cgColor
        addSubview(border)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak name] in
            App.shared.makeFirstResponder(name)
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func control(_: NSControl, textView: NSTextView, doCommandBy: Selector) -> Bool {
        if (doCommandBy == #selector(NSResponder.insertNewline(_:))) {
            create()
            return true
        }
        return false
    }
    
    @objc private func create() {
        App.shared.makeFirstResponder(nil)
        guard !name.stringValue.isEmpty else { return close() }
//        do {
//            try List.shared.folder.createFile(name.stringValue, user: App.shared.user)
//            App.shared.clear()
//            close()
//        } catch { Alert.shared.add(error) }
    }
}
