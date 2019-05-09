import Git
import UIKit

class Commit: Sheet {
    private class Layout: NSLayoutManager, NSLayoutManagerDelegate {
        private let padding = CGFloat(6)
        
        override init() {
            super.init()
            delegate = self
        }
        
        required init?(coder: NSCoder) { return nil }
        
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
    
    private class Text: UITextView {
        init() {
            let storage = NSTextStorage()
            super.init(frame: .zero, textContainer: {
                storage.addLayoutManager($1)
                $1.addTextContainer($0)
                $0.lineBreakMode = .byCharWrapping
                return $0
            } (NSTextContainer(), Layout()) )
            translatesAutoresizingMaskIntoConstraints = false
            backgroundColor = .clear
            alwaysBounceVertical = true
            textColor = .white
            tintColor = .halo
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
        
        required init?(coder: NSCoder) { return nil }
        
        override func caretRect(for position: UITextPosition) -> CGRect {
            var rect = super.caretRect(for: position)
            rect.size.width += 5
            return rect
        }
    }
    
    private weak var text: Text!
    private weak var bottom: NSLayoutConstraint!
    
    @discardableResult override init() {
        super.init()
        backgroundColor = .black
        
        let save = UIButton()
        save.translatesAutoresizingMaskIntoConstraints = false
        save.addTarget(self, action: #selector(self.save), for: .touchUpInside)
        save.setImage(#imageLiteral(resourceName: "commitOff.pdf"), for: .normal)
        save.setImage(#imageLiteral(resourceName: "commitOn.pdf"), for: .highlighted)
        addSubview(save)
        
        let icon = UIImageView(image: #imageLiteral(resourceName: "node.pdf"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.clipsToBounds = true
        icon.contentMode = .center
        addSubview(icon)
        
        let cancel = UIButton()
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        cancel.setImage(#imageLiteral(resourceName: "cancelOff.pdf"), for: .normal)
        cancel.setImage(#imageLiteral(resourceName: "cancelOn.pdf"), for: .highlighted)
        addSubview(cancel)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = .local("Commit.title")
        title.textColor = .halo
        title.font = .systemFont(ofSize: 20, weight: .medium)
        addSubview(title)
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.isUserInteractionEnabled = false
        border.backgroundColor = UIColor(white: 1, alpha: 0.2)
        addSubview(border)
        
        let text = Text()
        addSubview(text)
        self.text = text
        
        cancel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cancel.centerYAnchor.constraint(equalTo: save.centerYAnchor).isActive = true
        cancel.rightAnchor.constraint(equalTo: save.leftAnchor, constant: -10).isActive = true
        
        save.widthAnchor.constraint(equalToConstant: 50).isActive = true
        save.heightAnchor.constraint(equalToConstant: 50).isActive = true
        save.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        icon.centerYAnchor.constraint(equalTo: save.centerYAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 35).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        title.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10).isActive = true
        
        border.topAnchor.constraint(equalTo: save.bottomAnchor, constant: 10).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor, constant: -2).isActive = true
        
        text.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottom = text.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottom.isActive = true
        
        if #available(iOS 11.0, *) {
            save.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        } else {
            save.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { [weak self] in
            self?.bottom.constant = {
                $0.minY < App.view.view.frame.height ? -$0.height : 0
            } (($0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue)
            UIView.animate(withDuration:
            ($0.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue) { [weak self] in
                self?.layoutIfNeeded() }
        }
        
        ready = { [weak self] in
            self?.text?.becomeFirstResponder()
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    deinit { NotificationCenter.default.removeObserver(self) }
    
    @objc private func save() {
        App.repository?.commit(
            App.view.list.subviews.compactMap({ $0 as? List.Item }).filter({ $0.stage.isSelected }).map { $0.url },
            message: text.text, error: {
                App.view.alert.error($0.localizedDescription)
        }) { [weak self] in
            App.view.refresh()
            App.view.alert.commit(self?.text.text ?? "")
            self?.close()
        }
    }
}
