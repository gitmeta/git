import AppKit

final class Menu: NSMenu {
    init() {
        super.init(title: "")
        add(.local("Menu.git"), items: [
            NSMenuItem(title: .local("Menu.about"), action: #selector(App.about), keyEquivalent: ""),
            NSMenuItem.separator(),
            NSMenuItem(title: .local("Menu.preferences"), action: #selector(App.settings), keyEquivalent: ","),
            NSMenuItem.separator(),
            NSMenuItem(title: .local("Menu.hide"), action: #selector(App.hide(_:)), keyEquivalent: "h"),
            { $0.keyEquivalentModifierMask = [.option, .command]
                return $0
            } (NSMenuItem(title: .local("Menu.hideOthers"), action: #selector(App.hideOtherApplications(_:)), keyEquivalent: "h")),
            NSMenuItem(title: .local("Menu.showAll"), action: #selector(App.unhideAllApplications(_:)), keyEquivalent: ","),
            NSMenuItem.separator(),
            NSMenuItem(title: .local("Menu.quit"), action: #selector(App.terminate(_:)), keyEquivalent: "q")])
        
        add(.local("Menu.project"), items: [
            { $0.keyEquivalentModifierMask = [.command]
                return $0
            } (NSMenuItem(title: .local("Menu.directory"), action: #selector(App.browse), keyEquivalent: "o")),
            NSMenuItem.separator(),
            { $0.keyEquivalentModifierMask = [.command]
                return $0
            } (NSMenuItem(title: .local("Menu.refresh"), action: #selector(App.refresh), keyEquivalent: "r")),
            { $0.keyEquivalentModifierMask = [.command]
                return $0
            } (NSMenuItem(title: .local("Menu.log"), action: #selector(App.history), keyEquivalent: "y")),
            { $0.keyEquivalentModifierMask = [.command]
                return $0
            } (NSMenuItem(title: .local("Menu.commit"), action: #selector(App.add), keyEquivalent: "\r")),
            { $0.keyEquivalentModifierMask = [.command, .control, .shift]
                return $0
            } (NSMenuItem(title: .local("Menu.reset"), action: #selector(app.reset), keyEquivalent: "r"))])
        
        add(.local("Menu.window"), items: [
            NSMenuItem(title: .local("Menu.minimize"), action: #selector(Home.performMiniaturize(_:)), keyEquivalent: "m"),
            NSMenuItem(title: .local("Menu.zoom"), action: #selector(Home.performZoom(_:)), keyEquivalent: "p"),
            NSMenuItem.separator(),
            NSMenuItem(title: .local("Menu.bringAllToFront"), action: #selector(App.arrangeInFront(_:)), keyEquivalent: "")])
        
        add(.local("Menu.help"), items: [NSMenuItem(title: .local("Menu.showHelp"), action: #selector(App.help), keyEquivalent: "/")])
    }
    
    required init(coder: NSCoder) { fatalError() }
    
    private func add(_ title: String, items: [NSMenuItem]) {
        addItem({
            $0.submenu = {
                $0.items = items
                $0.autoenablesItems = false
                return $0
            } (NSMenu(title: title))
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
    }
}
