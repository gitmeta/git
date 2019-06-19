import UIKit

final class Market: UIView {
    private weak var loading: UIImageView!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let loading = UIImageView(image: UIImage(named: "loading"))
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.contentMode = .center
        loading.clipsToBounds = true
        addSubview(loading)
        self.loading = loading
        
        loading.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loading.widthAnchor.constraint(equalToConstant: 38).isActive = true
        loading.heightAnchor.constraint(equalToConstant: 38).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
}
