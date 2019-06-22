import UIKit

final class Settings: UIView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImageView(image: UIImage(named: "logo"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        addSubview(image)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .local("About.label")
        label.textColor = .halo
        label.font = .bold(18)
        addSubview(label)
        
        let version = UILabel()
        version.translatesAutoresizingMaskIntoConstraints = false
        version.text = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
        version.textColor = .halo
        version.font = .light(18)
        addSubview(version)
        
        let sign = Button.Yes(.local("Settings.buttonSign"))
        sign.addTarget(self, action: #selector(self.sign), for: .touchUpInside)
        
        let key = Button.Yes(.local("Settings.buttonKey"))
        key.addTarget(self, action: #selector(self.key), for: .touchUpInside)
        
        let delete = Button.Yes(.local("Settings.buttonDelete"))
        delete.addTarget(self, action: #selector(remove), for: .touchUpInside)
        delete.backgroundColor = .init(red: 1, green: 0.4, blue: 0.3, alpha: 1)
        
        let help = Button.No(.local("Settings.help"))
        help.addTarget(self, action: #selector(self.help), for: .touchUpInside)
        
        image.topAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 150).isActive = true
        image.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
        
        version.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        version.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        
        var top = version.bottomAnchor
        [sign, key, delete, help].forEach {
            addSubview($0)
            $0.topAnchor.constraint(equalTo: top, constant: 30).isActive = true
            $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            top = $0.bottomAnchor
        }
    }
    
    required init?(coder: NSCoder) { return nil }
    @objc private func sign() { Signature() }
    @objc private func key() { Credentials() }
    @objc private func help() { app.help() }
    
    @objc private func remove() { Delete() }
}
