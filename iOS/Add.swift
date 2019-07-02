import Git
import UIKit

final class Add: UIView {
    private final class Layout: NSLayoutManager, NSLayoutManagerDelegate {
        private let padding = CGFloat(6)
        
        required init?(coder: NSCoder) { return nil }
        override init() {
            super.init()
            delegate = self
        }
        
        func layoutManager(_: NSLayoutManager, shouldSetLineFragmentRect: UnsafeMutablePointer<CGRect>,
                           lineFragmentUsedRect: UnsafeMutablePointer<CGRect>, baselineOffset: UnsafeMutablePointer<CGFloat>,
                           in: NSTextContainer, forGlyphRange: NSRange) -> Bool {
            baselineOffset.pointee = baselineOffset.pointee + padding
            shouldSetLineFragmentRect.pointee.size.height += padding + padding
            lineFragmentUsedRect.pointee.size.height += padding + padding
            return true
        }
        
        override func setExtraLineFragmentRect(_ rect: CGRect, usedRect: CGRect, textContainer: NSTextContainer) {
            var rect = rect
            var used = usedRect
            rect.size.height += padding + padding
            used.size.height += padding + padding
            super.setExtraLineFragmentRect(rect, usedRect: used, textContainer: textContainer)
        }
    }
    
    final class Text: UITextView {
        private weak var height: NSLayoutConstraint!
        
        required init?(coder: NSCoder) { return nil }
        init() {
            let storage = NSTextStorage()
            super.init(frame: .zero, textContainer: {
                storage.addLayoutManager($1)
                $1.addTextContainer($0)
                return $0
            } (NSTextContainer(), Layout()))
            translatesAutoresizingMaskIntoConstraints = false
            backgroundColor = .clear
            alwaysBounceVertical = true
            textColor = .white
            tintColor = .halo
            keyboardDismissMode = .interactive
            font = .light(20)
            keyboardType = .alphabet
            keyboardAppearance = .dark
            autocorrectionType = .yes
            spellCheckingType = .yes
            autocapitalizationType = .sentences
            contentInset = .zero
            textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            indicatorStyle = .white
        }
        
        override func caretRect(for position: UITextPosition) -> CGRect {
            var rect = super.caretRect(for: position)
            rect.size.width += 5
            return rect
        }
    }
    
    private(set) weak var text: Text!
    private weak var bottom: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { return nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let border = UIView()
        border.isUserInteractionEnabled = true
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        addSubview(border)
        
        let button = Button.Yes(.key("Add.button"))
        button.addTarget(self, action: #selector(commit), for: .touchUpInside)
        addSubview(button)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 12, weight: .bold)
        title.textColor = .halo
        title.text = .key("Add.title")
        addSubview(title)
        
        let control = UIControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(text, action: #selector(text.resignFirstResponder), for: .touchUpInside)
        addSubview(control)
        
        let text = Text()
        addSubview(text)
        self.text = text
        
        control.topAnchor.constraint(equalTo: topAnchor).isActive = true
        control.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        control.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        control.rightAnchor.constraint(equalTo: button.leftAnchor).isActive = true
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        title.centerYAnchor.constraint(equalTo: topAnchor, constant: 27).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.bottomAnchor.constraint(equalTo: topAnchor, constant: 55).isActive = true
        
        button.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        button.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        
        text.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottom = text.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottom.isActive = true
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) {
            self.bottom.constant = {
                $0.minY < self.frame.height ? -($0.height - 62) : 0
            } (($0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue)
            UIView.animate(withDuration: ($0.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue) { self.layoutIfNeeded() }
        }
    }
    
    @objc private func commit() {
        text.resignFirstResponder()
        if Hub.session.name.isEmpty || Hub.session.email.isEmpty {
            app._settings.sign()
        } else {
            app.repository?.commit(
                app._home.list.subviews.compactMap({ $0 as? Home.Item }).filter({ $0.check.isSelected }).map { $0.url },
                message: text.text, error: { app.alert(.key("Alert.error"), message: $0.localizedDescription)
            }) {
                app.alert(.key("Alert.commit"), message: self.text.text)
                self.text.text = ""
                app.tab.history.choose()
                if app._history.content != nil {
                    app._history.load(true)
                }
            }
        }
    }
}
