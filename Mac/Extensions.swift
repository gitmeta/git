import AppKit

extension NSFont {
    final class func light(_ size: CGFloat) -> NSFont { return NSFont(name: "SFMono-Light", size: size)! }
    final class func bold(_ size: CGFloat) -> NSFont { return NSFont(name: "SFMono-Bold", size: size)! }
}

extension NSColor {
    static let halo = #colorLiteral(red: 0.231372549, green: 0.7215686275, blue: 1, alpha: 1)
    static let shade = #colorLiteral(red: 0.1058823529, green: 0.1490196078, blue: 0.1882352941, alpha: 1)
    static let untracked = #colorLiteral(red: 0.8874064701, green: 0.8861742914, blue: 0, alpha: 1)
    static let added = #colorLiteral(red: 0, green: 0.8377037809, blue: 0.7416605177, alpha: 1)
    static let modified = #colorLiteral(red: 0.802871919, green: 0.7154764525, blue: 1, alpha: 1)
    static let deleted = #colorLiteral(red: 0.2274509804, green: 0.7803921569, blue: 0.9176470588, alpha: 1)
}

final class Label: NSTextField {
    override var acceptsFirstResponder: Bool { return false }
    
    init(_ string: String = "") {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isBezeled = false
        isEditable = false
        isSelectable = false
        stringValue = string
    }
    
    required init?(coder: NSCoder) { return nil }
}

class Window: NSWindow {
    private(set) weak var name: Label!
    private(set) weak var border: NSView!
    var closabe = true
    
    override init(contentRect: NSRect, styleMask: NSWindow.StyleMask, backing: NSWindow.BackingStoreType, defer d: Bool) {
        super.init(contentRect: contentRect, styleMask: styleMask, backing: backing, defer: d)
    }
    
    init(_ width: CGFloat, _ height: CGFloat, style: NSWindow.StyleMask = []) {
        super.init(contentRect: NSRect(x: (NSScreen.main!.frame.width - width) / 2, y: (NSScreen.main!.frame.height - height) / 2, width: width, height: height), styleMask: [.closable, .fullSizeContentView, .titled, .unifiedTitleAndToolbar, .miniaturizable, style], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .black
        collectionBehavior = .fullScreenNone
        minSize = NSSize(width: 160, height: 160)
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        let name = Label()
        name.textColor = .halo
        name.font = .systemFont(ofSize: 12, weight: .bold)
        contentView!.addSubview(name)
        self.name = name
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = NSColor(white: 1, alpha: 0.3).cgColor
        contentView!.addSubview(border)
        self.border = border
        
        name.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 11).isActive = true
        name.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 80).isActive = true
        
        border.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 39).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    override func keyDown(with: NSEvent) {
        if closabe {
            switch with.keyCode {
            case 13:
                if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                    close()
                } else {
                    super.keyDown(with: with)
                }
            case 53: close()
            default: super.keyDown(with: with)
            }
        } else {
            super.keyDown(with: with)
        }
    }
}

final class Scroll: NSScrollView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        drawsBackground = false
        hasVerticalScroller = true
        verticalScroller!.controlSize = .mini
        horizontalScrollElasticity = .none
        verticalScrollElasticity = .allowed
    }
    
    func flip() {
        documentView = Flipped()
        documentView!.translatesAutoresizingMaskIntoConstraints = false
        documentView!.topAnchor.constraint(equalTo: topAnchor).isActive = true
        documentView!.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        documentView!.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
}

private final class Flipped: NSView { override var isFlipped: Bool { return true } }
