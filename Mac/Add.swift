import Git
import AppKit

final class Add: Window {
    private final class Layout: NSLayoutManager, NSLayoutManagerDelegate {
        private let padding = CGFloat(6)
        
        func layoutManager(_: NSLayoutManager, shouldSetLineFragmentRect: UnsafeMutablePointer<NSRect>,
                           lineFragmentUsedRect: UnsafeMutablePointer<NSRect>, baselineOffset: UnsafeMutablePointer<CGFloat>,
                           in: NSTextContainer, forGlyphRange: NSRange) -> Bool {
            baselineOffset.pointee = baselineOffset.pointee + padding
            shouldSetLineFragmentRect.pointee.size.height += padding + padding
            lineFragmentUsedRect.pointee.size.height += padding + padding
            return true
        }
        
        override func setExtraLineFragmentRect(_ rect: NSRect, usedRect: NSRect, textContainer: NSTextContainer) {
            var rect = rect
            var used = usedRect
            rect.size.height += padding + padding
            used.size.height += padding + padding
            super.setExtraLineFragmentRect(rect, usedRect: used, textContainer: textContainer)
        }
    }
    
    private final class Text: NSTextView {
        private weak var height: NSLayoutConstraint!
        
        init() {
            let storage = NSTextStorage()
            super.init(frame: .zero, textContainer: {
                $1.delegate = $1
                storage.addLayoutManager($1)
                $1.addTextContainer($0)
                $0.lineBreakMode = .byCharWrapping
                return $0
            } (NSTextContainer(), Layout()) )
            translatesAutoresizingMaskIntoConstraints = false
            allowsUndo = true
            drawsBackground = false
            isRichText = false
            insertionPointColor = .halo
            isContinuousSpellCheckingEnabled = true
            font = .light(18)
            textColor = .white
            textContainerInset = NSSize(width: 20, height: 20)
            height = heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
            height.isActive = true
            if #available(OSX 10.12.2, *) {
                isAutomaticTextCompletionEnabled = false
            }
        }
        
        required init?(coder: NSCoder) { return nil }
        
        override func resize(withOldSuperviewSize: NSSize) {
            super.resize(withOldSuperviewSize: withOldSuperviewSize)
            adjust()
        }
        
        override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn: Bool) {
            var rect = rect
            rect.size.width += 5
            super.drawInsertionPoint(in: rect, color: color, turnedOn: turnedOn)
        }
        
        override func didChangeText() {
            super.didChangeText()
            adjust()
        }
        
        override func viewDidEndLiveResize() {
            super.viewDidEndLiveResize()
            DispatchQueue.main.async { [weak self] in self?.adjust() }
        }
        
        private func adjust() {
            textContainer!.size.width = superview!.superview!.frame.width - (textContainerInset.width * 2)
            layoutManager!.ensureLayout(for: textContainer!)
            height.constant = layoutManager!.usedRect(for: textContainer!).size.height + (textContainerInset.height * 2)
        }
        
        override func keyDown(with: NSEvent) {
            switch with.keyCode {
            case 13:
                if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                    window!.close()
                } else {
                    super.keyDown(with: with)
                }
            case 53: window!.makeFirstResponder(nil)
            default: super.keyDown(with: with)
            }
        }
    }
    
    private weak var text: Text!
    
    init() {
        super.init(400, 400, style: .resizable)
        name.stringValue = .key("Add.title")
        
        let text = Text()
        self.text = text
        
        let scroll = Scroll()
        scroll.documentView = text
        contentView!.addSubview(scroll)
        
        let button = Button.Yes(self, action: #selector(commit))
        button.label.stringValue = .key("Add.button")
        contentView!.addSubview(button)
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -2).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        
        text.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        text.heightAnchor.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        
        button.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        button.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 20).isActive = true
    }
    
    @objc private func commit() {
        makeFirstResponder(nil)
        if Hub.session.name.isEmpty || Hub.session.email.isEmpty {
            app.settings()
            if let settings = app.windows.compactMap({ $0 as? Settings }).first {
                settings.sign()
            }
        } else {
            app.repository?.commit(
                app.home.list.documentView!.subviews.compactMap({ $0 as? Home.Item }).filter({ $0.check.checked }).map { $0.url },
                message: text.string, error: {
                    app.alert(.key("Alert.error"), message: $0.localizedDescription)
            }) { [weak self] in
                app.home.update(.loading)
                app.alert(.key("Alert.commit"), message: self?.text.string ?? "")
                self?.close()
                app.windows.compactMap({ $0 as? History }).first?.refresh()
            }
        }
    }
}
