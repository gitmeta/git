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
        addSubview(commit)

        let log = UIButton()
        log.translatesAutoresizingMaskIntoConstraints = false
        log.setImage(#imageLiteral(resourceName: "logOff.pdf"), for: .normal)
        log.setImage(#imageLiteral(resourceName: "logOn.pdf"), for: .highlighted)
        addSubview(log)
        
        heightAnchor.constraint(equalToConstant: 80).isActive = true

        commit.widthAnchor.constraint(equalToConstant: 65).isActive = true
        commit.heightAnchor.constraint(equalToConstant: 65).isActive = true
        commit.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        commit.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        log.widthAnchor.constraint(equalToConstant: 50).isActive = true
        log.heightAnchor.constraint(equalToConstant: 50).isActive = true
        log.rightAnchor.constraint(equalTo: commit.leftAnchor, constant: -10).isActive = true
        log.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    @objc private func log() { /*Log()*/ }
    @objc private func preferences() { Credentials() }
    @objc func commit() {
        if Hub.session.name.isEmpty || Hub.session.email.isEmpty {
            preferences()
        } else {
            Commit()
        }
    }
}
