import Git
import UIKit

final class Settings: UIView {
    required init?(coder: NSCoder) { return nil }
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
        label.text = .key("About.label")
        label.textColor = .halo
        label.font = .bold(20)
        addSubview(label)
        
        let version = UILabel()
        version.translatesAutoresizingMaskIntoConstraints = false
        version.text = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
        version.textColor = .halo
        version.font = .light(13)
        addSubview(version)
        
        let sign = Button.Yes(.key("Settings.buttonSign"))
        sign.addTarget(self, action: #selector(self.sign), for: .touchUpInside)
        
        let key = Button.Yes(.key("Settings.buttonKey"))
        key.addTarget(self, action: #selector(self.key), for: .touchUpInside)
        
        let delete = Button.Yes(.key("Settings.buttonDelete"))
        delete.addTarget(self, action: #selector(remove), for: .touchUpInside)
        delete.backgroundColor = .init(red: 1, green: 0.4, blue: 0.3, alpha: 1)
        
        let help = Button.No(.key("Settings.help"))
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

    @objc private func help() { app.help() }
    @objc private func remove() { Delete() }
    
    @objc func sign() {
        let credentials = Credentials()
        credentials.title.text = .key("Settings.labelSign")
        credentials.first.label.text = .key("Settings.signName")
        credentials.first.field.keyboardType = .alphabet
        credentials.first.field.text = Hub.session.name
        credentials.second.label.text = .key("Settings.signEmail")
        credentials.second.field.keyboardType = .emailAddress
        credentials.second.field.text = Hub.session.email
        credentials.done = {
            Hub.session.update($0, email: $1, error: {
                app.alert(.key("Alert.error"), message: $0.localizedDescription)
            }) { [weak credentials] in
                app.alert(.key("Alert.success"), message: .key("Settings.signSuccess"))
                credentials?.close()
            }
        }
    }
    
    @objc private func key() {
        let credentials = Credentials()
        credentials.title.text = .key("Settings.labelKey")
        credentials.first.label.text = .key("Settings.keyUser")
        credentials.first.field.keyboardType = .emailAddress
        credentials.first.field.text = Hub.session.user
        credentials.second.label.text = .key("Settings.keyPassword")
        credentials.second.field.isSecureTextEntry = true
        credentials.second.field.keyboardType = .alphabet
        credentials.second.field.text = Hub.session.password
        credentials.done = {
            Hub.session.update($0, password: $1) { [weak credentials] in
                app.alert(.key("Alert.success"), message: .key("Settings.keySuccess"))
                credentials?.close()
            }
        }
    }
}
