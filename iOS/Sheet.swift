import UIKit

class Sheet: UIView {
    private(set) weak var base: UIView!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.halo.withAlphaComponent(0)
        let parent = app.presentedViewController?.view ?? app.view!
        parent.addSubview(self)
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = .black
        base.layer.cornerRadius = 6
        base.clipsToBounds = true
        addSubview(base)
        self.base = base
        
        topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        let bottom = base.bottomAnchor.constraint(equalTo: topAnchor)
        bottom.isActive = true
        
        DispatchQueue.main.async {
            parent.layoutIfNeeded()
            bottom.constant = 40 + base.frame.height
            UIView.animate(withDuration: 0.45) { [weak self] in
                self?.backgroundColor = UIColor.halo.withAlphaComponent(0.85)
                self?.layoutIfNeeded()
            }
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    
    @objc final func close() {
        app.window!.endEditing(true)
        UIView.animate(withDuration: 0.35, animations: { [weak self] in
            self?.alpha = 0
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
}
