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
        label.font = .bold(16)
        addSubview(label)
        
        let version = UILabel()
        version.translatesAutoresizingMaskIntoConstraints = false
        version.text = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
        version.textColor = .halo
        version.font = .light(16)
        addSubview(version)
        
        let refresh = Button.Yes(.local("Settings.refresh"))
        refresh.addTarget(self, action: #selector(self.refresh), for: .touchUpInside)
        addSubview(refresh)
        
        let sign = Button.Yes(.local("Settings.buttonSign"))
        sign.addTarget(self, action: #selector(self.sign), for: .touchUpInside)
        addSubview(sign)
        
        let key = Button.Yes(.local("Settings.buttonKey"))
        key.addTarget(self, action: #selector(self.key), for: .touchUpInside)
        addSubview(key)
        
        let help = Button.No(.local("Settings.help"))
        help.addTarget(self, action: #selector(self.help), for: .touchUpInside)
        addSubview(help)
        
        image.topAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 150).isActive = true
        image.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
        
        version.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        version.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        
        refresh.topAnchor.constraint(equalTo: version.bottomAnchor, constant: 50).isActive = true
        refresh.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        sign.topAnchor.constraint(equalTo: refresh.bottomAnchor, constant: 20).isActive = true
        sign.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        key.topAnchor.constraint(equalTo: sign.bottomAnchor, constant: 20).isActive = true
        key.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        help.topAnchor.constraint(equalTo: key.bottomAnchor, constant: 40).isActive = true
        help.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    @objc private func sign() { Signature() }
    @objc private func key() { Credentials() }
    @objc private func help() { Credentials() }
    
    @objc private func refresh() {
        app.refresh()
        app.alert(.local("Alert.success"), message: .local("Settings.refreshed"))
    }
}
