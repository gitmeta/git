import AppKit

class Button: NSView {
    class Image: Button {
        var off: NSImage? { didSet { image.image = off } }
        var on: NSImage?
        private weak var image: NSImageView!
        override var selected: Bool {
            didSet {
                image.image = selected ? on : off
            }
        }
        
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            let image = NSImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.imageScaling = .scaleNone
            addSubview(image)
            self.image = image
            
            image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            image.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            image.topAnchor.constraint(equalTo: topAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    class Text: Button {
        private(set) weak var label: Label!
        override var selected: Bool {
            didSet {
                alphaValue = selected ? 0.5 : 1
            }
        }
        
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            let label = Label()
            label.alignment = .center
            self.label = label
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    class Check: Button {
        var checked = false { didSet {
            if checked {
                image.image = on
            } else {
                image.image = off
            }
        } }
        var off: NSImage? { didSet { image.image = off } }
        var on: NSImage?
        private weak var image: NSImageView!
        
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            let image = NSImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.imageScaling = .scaleNone
            addSubview(image)
            self.image = image
            
            image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            image.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            image.topAnchor.constraint(equalTo: topAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
        
        override func click() {
            checked.toggle()
            super.click()
        }
    }
    
    weak var target: AnyObject?
    var action: Selector?
    private(set) weak var width: NSLayoutConstraint!
    private(set) weak var height: NSLayoutConstraint!
    fileprivate var selected = false
    private var drag = CGFloat(0)
    
    init(_ target: AnyObject?, action: Selector?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.target = target
        self.action = action
        
        width = widthAnchor.constraint(equalToConstant: 0)
        height = heightAnchor.constraint(equalToConstant: 0)
        width.isActive = true
        height.isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    override func mouseDown(with: NSEvent) { selected = true }
    
    override func mouseDragged(with: NSEvent) {
        drag += abs(with.deltaX) + abs(with.deltaY)
        if drag > 20 {
            selected = false
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if selected {
            click()
        }
        selected = false
    }
    
    fileprivate func click() {
        _ = target?.perform(action)
    }
}
