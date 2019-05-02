import AppKit

class Text: NSTextView {
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
        font = .light(18)
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
        rect.size.width += 2
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
