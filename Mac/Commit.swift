import Git
import AppKit

class Commit: Sheet {
    private class Layout: NSLayoutManager, NSLayoutManagerDelegate {
        private let padding = CGFloat(6)
        
        override init() {
            super.init()
            delegate = self
        }
        
        required init?(coder: NSCoder) { return nil }
        
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
    
    private class Text: NSTextView {
        private weak var height: NSLayoutConstraint!
        
        init() {
            let storage = NSTextStorage()
            super.init(frame: .zero, textContainer: {
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
            font = .light(20)
            textColor = .white
            textContainerInset = NSSize(width: 20, height: 20)
            height = heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
            height.isActive = true
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
    }

    private weak var text: Text!
    
    @discardableResult override init() {
        super.init()
        let save = Button.Image(self, action: #selector(self.save))
        save.off = NSImage(named: "commitOff")
        save.on = NSImage(named: "commitOn")
        save.width.constant = 40
        save.height.constant = 40
        addSubview(save)
        
        let cancel = Button.Image(self, action: #selector(close))
        cancel.off = NSImage(named: "cancelOff")
        cancel.on = NSImage(named: "cancelOn")
        cancel.width.constant = 40
        cancel.height.constant = 40
        addSubview(cancel)
        
        let title = Label(.local("Commit.title"))
        title.textColor = .halo
        title.font = .systemFont(ofSize: 14, weight: .bold)
        addSubview(title)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = NSColor.black.cgColor
        addSubview(border)
        
        let text = Text()
        self.text = text
        
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.drawsBackground = false
        scroll.documentView = text
        scroll.hasVerticalScroller = true
        scroll.verticalScroller!.controlSize = .mini
        scroll.horizontalScrollElasticity = .none
        scroll.verticalScrollElasticity = .allowed
        addSubview(scroll)
        
        cancel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        cancel.rightAnchor.constraint(equalTo: save.leftAnchor).isActive = true
        
        save.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        save.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        title.centerYAnchor.constraint(equalTo: save.centerYAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: cancel.leftAnchor, constant: -10).isActive = true
        
        border.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor, constant: -2).isActive = true
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -2).isActive = true
        
        text.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        text.heightAnchor.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        
        ready = { [weak self] in
            App.window.makeFirstResponder(self?.text)
        }
    }
    
    required init?(coder: NSCoder) { return nil }

    @objc private func save() {
        App.repository?.commit(
            (App.window.list.documentView!.subviews as! [List.Item]).filter({ $0.stage.checked }).map { $0.url },
            message: text.string, error: {
                App.window.alert.error($0.localizedDescription)
        }) { [weak self] in
            App.window.showRefresh()
            App.window.alert.commit(self?.text.string ?? "")
            self?.close()
        }
    }
}
