import UIKit

class Pop: UIView {
    private(set) weak var name: UILabel!
    private(set) weak var separator: UIView!
    private(set) weak var loading: UIImageView!
    private(set) weak var close: UIButton!
    private weak var top: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { return nil }
    init() {
        app.view.isUserInteractionEnabled = false
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black
        app.view.addSubview(self)
        
        let border = UIView()
        border.isUserInteractionEnabled = false
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        addSubview(border)
        
        let separator = UIView()
        separator.isUserInteractionEnabled = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .halo
        addSubview(separator)
        self.separator = separator
        
        let close = UIButton()
        close.addTarget(self, action: #selector(closing), for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false
        close.setImage(UIImage(named: "close"), for: .normal)
        close.imageView!.contentMode = .center
        close.imageView!.clipsToBounds = true
        addSubview(close)
        self.close = close
        
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textColor = .halo
        name.font = .systemFont(ofSize: 14, weight: .bold)
        addSubview(name)
        self.name = name
        
        let loading = UIImageView(image: UIImage(named: "loading"))
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.clipsToBounds = true
        loading.contentMode = .center
        addSubview(loading)
        self.loading = loading
        
        leftAnchor.constraint(equalTo: app.view.leftAnchor).isActive = true
        widthAnchor.constraint(equalTo: app.view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: app.view.heightAnchor, constant: 3).isActive = true
        top = topAnchor.constraint(equalTo: app.view.topAnchor, constant: app.view.bounds.height)
        top.isActive = true
        
        border.topAnchor.constraint(equalTo: topAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 3).isActive = true
        
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        close.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        close.bottomAnchor.constraint(equalTo: separator.topAnchor).isActive = true
        close.heightAnchor.constraint(equalToConstant: 55).isActive = true
        close.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        name.centerYAnchor.constraint(equalTo: close.centerYAnchor, constant: 1).isActive = true
        name.leftAnchor.constraint(equalTo: close.rightAnchor).isActive = true
        
        loading.widthAnchor.constraint(equalToConstant: 100).isActive = true
        loading.heightAnchor.constraint(equalToConstant: 40).isActive = true
        loading.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            separator.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 58).isActive = true
        } else {
            separator.topAnchor.constraint(equalTo: topAnchor, constant: 58).isActive = true
        }
        
        app.view.layoutIfNeeded()
        top.constant = -3
        
        UIView.animate(withDuration: 0.4, animations: {
            app.view.layoutIfNeeded()
        }) { [weak self] _ in self?.ready() }
    }
    
    func ready() { app.view.isUserInteractionEnabled = true }
    
    @objc private func closing() {
        top.constant = bounds.height
        UIView.animate(withDuration: 0.3, animations: {
            app.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
}
