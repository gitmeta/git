import UIKit

class Sheet: UIView {
    var ready: (() -> Void)?
    var closing: (() -> Void)?
    
    init() {
//        app.endEditing(true)
        super.init(frame: .zero)
        alpha = 0
        translatesAutoresizingMaskIntoConstraints = false
        app.view.addSubview(self)
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.isUserInteractionEnabled = false
        addSubview(blur)
        
        blur.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blur.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blur.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        blur.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        topAnchor.constraint(equalTo: app.view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: app.view.bottomAnchor).isActive = true
        leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: app.view.rightAnchor).isActive = true
        
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.alpha = 1
        }) { [weak self] _ in self?.ready?() }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc func close() {
//        App.shared.endEditing(true)
//        UIView.animate(withDuration: 0.3, animations: { [weak self] in
//            self?.alpha = 0
//        }) { [weak self] _ in
//            self?.closing?()
//            self?.removeFromSuperview()
//        }
    }
}
