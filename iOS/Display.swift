import UIKit

class Display: UIView {
    private weak var image: UIImageView!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImageView(image: #imageLiteral(resourceName: "logo.pdf"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        addSubview(image)
        self.image = image
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
}
