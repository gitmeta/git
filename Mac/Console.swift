import AppKit

class Console: NSView {
    private weak var text: NSTextView!
    private let format = DateFormatter()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.drawsBackground = false
        scroll.documentView = {
            $0.drawsBackground = false
            $0.isRichText = false
            $0.textContainerInset = NSSize(width: 10, height: 10)
            $0.isVerticallyResizable = true
            $0.isHorizontallyResizable = true
            $0.isEditable = false
            $0.textContainer!.lineBreakMode = .byCharWrapping
            text = $0
            return $0
        } (NSTextView())
        scroll.horizontalScrollElasticity = .none
        addSubview(scroll)
        
        scroll.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        format.dateStyle = .none
        format.timeStyle = .medium
    }
    
    required init?(coder: NSCoder) { return nil }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        text.frame = CGRect(x: 0, y: 0, width: bounds.width, height: text.frame.height)
    }
    
    func log(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.text.textStorage!.append({
                $0.append(NSAttributedString(string: self.format.string(from: Date()) + " ", attributes: [
                    .font: NSFont.light(12), .foregroundColor: NSColor.halo]))
                $0.append(NSAttributedString(string: message + "\n", attributes: [
                    .font: NSFont.light(12), .foregroundColor: NSColor(white: 1, alpha: 1)]))
                return $0
                } (NSMutableAttributedString()))
            DispatchQueue.main.async { [weak self] in self?.scroll() }
        }
    }
    
    private func scroll() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            context.allowsImplicitAnimation = true
            text.scrollRangeToVisible(NSMakeRange(text.textStorage!.length, 0))
        }) { }
    }
}
