import AppKit

class Menu: NSMenu {
    private(set) weak var project: NSMenuItem!
    
    init() {
        super.init(title: "")
        
        addItem({
            $0.submenu = {
                $0.addItem(withTitle: .local("Menu.about"), action:
                    #selector(App.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
                $0.addItem(NSMenuItem.separator())
                $0.addItem({
                    $0.target = self
                    return $0
                } (NSMenuItem(title: .local("Menu.preferences"), action: #selector(preferences), keyEquivalent: ",")))
                $0.addItem(NSMenuItem.separator())
                $0.addItem(withTitle: .local("Menu.hide"), action: #selector(App.hide(_:)), keyEquivalent: "h")
                $0.addItem({
                    $0.keyEquivalentModifierMask = [.option, .command]
                    return $0
                } (NSMenuItem(title: .local("Menu.hideOthers"), action:
                    #selector(App.hideOtherApplications(_:)), keyEquivalent: "h")))
                $0.addItem(withTitle: .local("Menu.showAll"), action:
                    #selector(App.unhideAllApplications(_:)), keyEquivalent: "")
                $0.addItem(NSMenuItem.separator())
                $0.addItem(withTitle: .local("Menu.quit"), action: #selector(App.terminate(_:)), keyEquivalent: "q")
                return $0
            } (NSMenu(title: .local("Menu.git")))
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        addItem({
            $0.submenu = {
                $0.addItem({
                    $0.target = self
                    return $0
                } (NSMenuItem(title: .local("Menu.directory"), action: #selector(directory), keyEquivalent: ",")))
                $0.addItem(NSMenuItem.separator())
                $0.addItem({
                    $0.keyEquivalentModifierMask = [.option, .command]
                    return $0
                } (NSMenuItem(title: .local("Menu.commit"), action: #selector(commit), keyEquivalent: "h")))
                return $0
            } (NSMenu(title: .local("Menu.project")))
            project = $0
            $0.isEnabled = false
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        addItem({
            $0.submenu = {
                $0.addItem(withTitle: .local("Menu.minimize"), action:
                    #selector(Window.performMiniaturize(_:)), keyEquivalent: "m")
                $0.addItem(withTitle: .local("Menu.zoom"), action: #selector(Window.performZoom(_:)), keyEquivalent: "p")
                $0.addItem(NSMenuItem.separator())
                $0.addItem(withTitle: .local("Menu.bringAllToFront"), action:
                    #selector(App.arrangeInFront(_:)), keyEquivalent: "")
                return $0
            } (NSMenu(title: .local("Menu.window")))
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        addItem({
            $0.submenu = {
                $0.addItem(withTitle: .local("Menu.showHelp"), action: #selector(App.showHelp(_:)), keyEquivalent: "/")
                return $0
            } (NSMenu(title: .local("Menu.help")))
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
    }
    
    required init(coder: NSCoder) { fatalError() }
    @objc private func preferences() { Credentials() }
    @objc private func directory() { }
    @objc private func commit() { }
}
