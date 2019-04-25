import AppKit

class Menu: NSMenu {
    private(set) static var shared: Menu!
    @IBOutlet private(set) weak var directory: NSMenuItem!
    @IBOutlet private(set) weak var commit: NSMenuItem!
    @IBOutlet private(set) weak var preferences: NSMenuItem!
    
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
    
    @objc private func showPreferences() {
        User()
    }
    
    @objc private func changeDirectory() {
        App.shared.prompt()
    }
    
    @objc private func makeCommit() {
        App.shared.tools.commit()
    }
}
