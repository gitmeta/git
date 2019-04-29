import AppKit

class Menu: NSMenu {
    init() {
        super.init(title: "hello world")
        let main = NSMenu()
        main.addItem(withTitle: .local("Menu.about"), action:
            #selector(App.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        main.addItem(NSMenuItem.separator())
        let preferences = NSMenuItem(title: .local("Menu.preferences"), action: #selector(self.preferences), keyEquivalent: ",")
        preferences.target = self
        main.addItem(preferences)
        main.addItem(NSMenuItem.separator())
        main.addItem(withTitle: .local("Menu.quit"), action: #selector(App.terminate(_:)), keyEquivalent: "q")
        addItem(withTitle: "", action: nil, keyEquivalent: "").submenu = main
    }
    
    required init(coder: NSCoder) { fatalError() }
    
    func refresh() {
//        commit.isEnabled = App.shared.repository != nil
    }
    
    @objc private func preferences() { Credentials() }
    
    @objc private func changeDirectory() {
//        App.shared.prompt()
    }
    
    @objc private func makeCommit() {
//        App.shared.tools.commit()
    }
}
