import Git
import UIKit

class View: UIViewController {
    private weak var branch: Bar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let display = Display()
        view.addSubview(display)
        
        let location = Bar.Location()
        view.addSubview(location)
        
        let branch = Bar.Branch()
        view.addSubview(branch)
        self.branch = branch
        
        display.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        display.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        display.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        display.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        location.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 7).isActive = true
        
        branch.topAnchor.constraint(equalTo: location.topAnchor).isActive = true
        branch.leftAnchor.constraint(equalTo: location.rightAnchor, constant: -16).isActive = true
        branch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -7).isActive = true
        
        if #available(iOS 11.0, *) {
            location.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        } else {
            location.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        }
        
        Hub.session.load {
            if Hub.session.bookmark.isEmpty {
//                Onboard()
            } else {
                
            }
        }
    }
}
