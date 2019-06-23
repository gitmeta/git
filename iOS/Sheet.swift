import UIKit

class Sheet: UIView {
    var height = CGFloat(300)
    private(set) weak var base: UIView!
    
    init() {
        super.init(frame: .zero)
        guard !app.view.subviews.contains(where: { $0 is Signature }) else { return }
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.halo.withAlphaComponent(0)
        app.view.addSubview(self)
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .black
        base.layer.cornerRadius = 6
        base.clipsToBounds = true
        addSubview(base)
        self.base = base
        
        topAnchor.constraint(equalTo: app.view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: app.view.bottomAnchor).isActive = true
        leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: app.view.rightAnchor).isActive = true
        
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        base.heightAnchor.constraint(equalToConstant: height).isActive = true
        let top = base.topAnchor.constraint(equalTo: topAnchor, constant: -height)
        top.isActive = true
        
        app.view.layoutIfNeeded()
        
        top.constant = 40
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.backgroundColor = UIColor.halo.withAlphaComponent(0.8)
            self?.layoutIfNeeded()
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc final func close() {
        app.window!.endEditing(true)
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.alpha = 0
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
}
