import Git
import UIKit

class Tools: UIView {
    weak var top: NSLayoutConstraint! { didSet { top.isActive = true } }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .black

        let commit = UIButton()
        commit.translatesAutoresizingMaskIntoConstraints = false
        commit.addTarget(self, action: #selector(self.commit), for: .touchUpInside)
        commit.setImage(#imageLiteral(resourceName: "addOff.pdf"), for: .normal)
        commit.setImage(#imageLiteral(resourceName: "addOn.pdf"), for: .highlighted)
        commit.imageView!.clipsToBounds = true
        commit.imageView!.contentMode = .center
        addSubview(commit)

        let log = UIButton()
        log.translatesAutoresizingMaskIntoConstraints = false
        log.addTarget(self, action: #selector(self.log), for: .touchUpInside)
        log.setImage(#imageLiteral(resourceName: "logOff.pdf"), for: .normal)
        log.setImage(#imageLiteral(resourceName: "logOn.pdf"), for: .highlighted)
        log.imageView!.clipsToBounds = true
        log.imageView!.contentMode = .center
        addSubview(log)
        
        let credentials = UIButton()
        credentials.translatesAutoresizingMaskIntoConstraints = false
        credentials.addTarget(App.view, action: #selector(View.credentials), for: .touchUpInside)
        credentials.setImage(#imageLiteral(resourceName: "credentialsOff.pdf"), for: .normal)
        credentials.setImage(#imageLiteral(resourceName: "credentialsOn.pdf"), for: .highlighted)
        credentials.imageView!.clipsToBounds = true
        credentials.imageView!.contentMode = .center
        addSubview(credentials)
        
        let reset = UIButton()
        reset.translatesAutoresizingMaskIntoConstraints = false
        reset.addTarget(self, action: #selector(self.reset), for: .touchUpInside)
        reset.setImage(#imageLiteral(resourceName: "resetOff.pdf"), for: .normal)
        reset.setImage(#imageLiteral(resourceName: "resetOn.pdf"), for: .highlighted)
        reset.imageView!.clipsToBounds = true
        reset.imageView!.contentMode = .center
        addSubview(reset)
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true

        commit.widthAnchor.constraint(equalToConstant: 65).isActive = true
        commit.heightAnchor.constraint(equalToConstant: 65).isActive = true
        commit.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        commit.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true

        log.widthAnchor.constraint(equalToConstant: 50).isActive = true
        log.heightAnchor.constraint(equalToConstant: 50).isActive = true
        log.rightAnchor.constraint(equalTo: commit.leftAnchor, constant: -20).isActive = true
        log.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        
        credentials.widthAnchor.constraint(equalToConstant: 50).isActive = true
        credentials.heightAnchor.constraint(equalToConstant: 50).isActive = true
        credentials.rightAnchor.constraint(equalTo: log.leftAnchor, constant: -20).isActive = true
        credentials.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        
        reset.widthAnchor.constraint(equalToConstant: 50).isActive = true
        reset.heightAnchor.constraint(equalToConstant: 50).isActive = true
        reset.leftAnchor.constraint(equalTo: commit.rightAnchor, constant: 20).isActive = true
        reset.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    @objc private func log() { Log() }
    @objc private func preferences() { Credentials() }
    @objc private func reset() { Reset() }
    @objc func commit() {
        if Hub.session.name.isEmpty || Hub.session.email.isEmpty {
            preferences()
        } else {
            Commit()
        }
    }
}
