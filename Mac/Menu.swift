import AppKit

class Menu: NSMenu {
    private(set) static var shared: Menu!
    @IBOutlet private weak var directory: NSMenuItem!
    @IBOutlet private weak var commit: NSMenuItem!
    @IBOutlet private weak var preferences: NSMenuItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Menu.shared = self
        
        directory.target = self
        directory.action = #selector(changeDirectory)
        
        commit.target = self
        commit.action = #selector(makeCommit)
        
        preferences.target = self
        preferences.action = #selector(showPreferences)
    }
    
    func refresh() {
        commit.isEnabled = App.shared.repository != nil
    }
    
    @objc private func showPreferences() {
        Credentials()
    }
    
    @objc private func changeDirectory() {
        App.shared.prompt()
    }
    
    @objc private func makeCommit() {
        App.shared.tools.commit()
    }
}
