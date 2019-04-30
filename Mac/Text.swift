import AppKit

class Text: NSTextView {
    private weak var placeholder: Label!
    private weak var height: NSLayoutConstraint!
    
    init() {
        let storage = Storage()
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
        font = .light(16)
        textContainerInset = NSSize(width: 15, height: 15)
        height = heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        height.isActive = true
        
        let placeholder = Label(.local("Text.placeholder"))
        placeholder.textColor = NSColor(white: 1, alpha: 0.5)
        placeholder.font = .light(18)
        addSubview(placeholder)
        self.placeholder = placeholder
        
        placeholder.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        placeholder.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func resize(withOldSuperviewSize: NSSize) {
        super.resize(withOldSuperviewSize: withOldSuperviewSize)
        adjust()
    }
    
    override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn: Bool) {
        var rect = rect
        rect.size.width += 2
        super.drawInsertionPoint(in: rect, color: color, turnedOn: turnedOn)
    }
    
    override func didChangeText() {
        super.didChangeText()
        placeholder.isHidden = !string.isEmpty
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
