import AppKit

class Button: NSView {
    final class Image: Button {
        private(set) weak var image: NSImageView!
        
        required init?(coder: NSCoder) { return nil }
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
    }
    
    final class Check: Button {
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
        
        required init?(coder: NSCoder) { return nil }
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
        
        override func click() {
            checked.toggle()
            super.click()
        }
    }
    
    final class Yes: Text {
        private(set) weak var width: NSLayoutConstraint!
        
        required init?(coder: NSCoder) { return nil }
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            wantsLayer = true
            layer!.cornerRadius = 3
            layer!.backgroundColor = NSColor.halo.cgColor
            label.alignment = .center
            label.font = .systemFont(ofSize: 11, weight: .medium)
            label.textColor = .black
            
            heightAnchor.constraint(equalToConstant: 20).isActive = true
            width = widthAnchor.constraint(equalToConstant: 62)
            width.isActive = true
        }
    }
    
    class Text: Button {
        private(set) weak var label: Label!
        
        required init?(coder: NSCoder) { return nil }
        override init(_ target: AnyObject?, action: Selector?) {
            super.init(target, action: action)
            let label = Label()
            self.label = label
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    final weak var target: AnyObject?
    final var action: Selector?
    final var enabled = true
    private var drag = CGFloat(0)
    final fileprivate var selected = false {
        didSet {
            alphaValue = selected ? 0.4 : 1
        }
    }

    required init?(coder: NSCoder) { return nil }
    init(_ target: AnyObject?, action: Selector?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.target = target
        self.action = action
    }

    override func resetCursorRects() {
        if enabled {
            addCursorRect(bounds, cursor: .pointingHand)
        }
    }
    
    override func mouseDown(with: NSEvent) {
        if enabled {
            selected = true
        }
    }
    
    override func mouseDragged(with: NSEvent) {
        if enabled {
            drag += abs(with.deltaX) + abs(with.deltaY)
            if drag > 20 {
                selected = false
            }
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if enabled {
            if selected {
                click()
            }
            selected = false
        }
    }
    
    fileprivate func click() {
        _ = target?.perform(action, with: self)
    }
}
