import UIKit

class Display: UIView {
    /*
    private weak var image: UIImageView!
    private weak var create: UIButton!
    private weak var message: UILabel!
    private weak var spinner: UIImageView!
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let spinner = UIImageView(image: #imageLiteral(resourceName: "loading.pdf"))
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.contentMode = .center
        spinner.clipsToBounds = true
        spinner.isHidden = true
        addSubview(spinner)
        self.spinner = spinner
        
        let image = UIImageView(image: #imageLiteral(resourceName: "logo.pdf"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        addSubview(image)
        self.image = image
        
        let message = UILabel()
        message.translatesAutoresizingMaskIntoConstraints = false
        message.font = .systemFont(ofSize: 12, weight: .regular)
        message.textColor = UIColor(white: 1, alpha: 0.6)
        message.textAlignment = .center
        message.numberOfLines = 0
        addSubview(message)
        self.message = message

        let create = UIButton()
        create.translatesAutoresizingMaskIntoConstraints = false
        create.addTarget(App.shared, action: #selector(App.create), for: .touchUpInside)
        create.setTitle(.local("Display.create"), for: [])
        create.titleLabel!.font = .systemFont(ofSize: 14, weight: .bold)
        create.layer.cornerRadius = 6
        create.backgroundColor = .halo
        create.setTitleColor(.black, for: .normal)
        create.setTitleColor(UIColor(white: 0, alpha: 0.2), for: .highlighted)
        create.isHidden = true
        addSubview(create)
        self.create = create
        
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        message.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        message.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
        message.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        create.widthAnchor.constraint(equalToConstant: 80).isActive = true
        create.heightAnchor.constraint(equalToConstant: 34).isActive = true
        create.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        create.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 30).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func loading() {
        alpha = 1
        image.image = nil
        spinner.isHidden = false
        message.text = ""
        create.isHidden = true
    }
    
    func repository() {
        alpha = 0
        image.image = nil
        spinner.isHidden = true
        message.text = ""
        create.isHidden = true
    }
    
    func notRepository() {
        alpha = 1
        image.image = #imageLiteral(resourceName: "error.pdf")
        spinner.isHidden = true
        message.text = .local("Display.notRepository")
        create.isHidden = false
    }
    
    func upToDate() {
        alpha = 1
        image.image = #imageLiteral(resourceName: "updated.pdf")
        spinner.isHidden = true
        message.text = .local("Display.upToDate")
        create.isHidden = true
    }
 
 */
}
