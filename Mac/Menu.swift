import AppKit

class Menu: NSMenu {
    private weak var preferences: NSMenuItem!
    private weak var directory: NSMenuItem!
    private weak var refresh: NSMenuItem!
    private weak var log: NSMenuItem!
    private weak var commit: NSMenuItem!
    private weak var reset: NSMenuItem!
    private weak var help: NSMenuItem!
    
    init() {
        super.init(title: "")
        
        addItem({
            $0.submenu = {
                $0.addItem(withTitle: .local("Menu.about"), action:
                    #selector(App.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
                $0.addItem(NSMenuItem.separator())
                $0.addItem({
                    $0.target = App.global
                    preferences = $0
                    return $0
                } (NSMenuItem(title: .local("Menu.preferences"), action: #selector(App.preferences), keyEquivalent: ",")))
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
                $0.autoenablesItems = false
                return $0
            } (NSMenu(title: .local("Menu.git")))
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        addItem({
            $0.submenu = {
                $0.addItem({
                    $0.target = App.global
                    $0.keyEquivalentModifierMask = [.command]
                    directory = $0
                    return $0
                } (NSMenuItem(title: .local("Menu.directory"), action: #selector(App.panel), keyEquivalent: "o")))
                $0.addItem(NSMenuItem.separator())
                $0.addItem({
                    $0.keyEquivalentModifierMask = [.command]
                    $0.target = App.global
                    $0.isEnabled = false
                    refresh = $0
                    return $0
                } (NSMenuItem(title: .local("Menu.refresh"), action: #selector(App.refresh), keyEquivalent: "r")))
                $0.addItem({
                    $0.keyEquivalentModifierMask = [.command]
                    $0.target = App.home.tools
                    $0.isEnabled = false
                    log = $0
                    return $0
                } (NSMenuItem(title: .local("Menu.log"), action: #selector(Tools.log), keyEquivalent: "y")))
                $0.addItem({
                    $0.keyEquivalentModifierMask = [.command]
                    $0.target = App.home.tools
                    $0.isEnabled = false
                    commit = $0
                    return $0
                } (NSMenuItem(title: .local("Menu.commit"), action: #selector(Tools.commit), keyEquivalent: "\r")))
                $0.addItem(NSMenuItem.separator())
                $0.addItem({
                    $0.keyEquivalentModifierMask = [.command, .control, .shift]
                    $0.target = App.home.tools
                    $0.isEnabled = false
                    reset = $0
                    return $0
                    } (NSMenuItem(title: .local("Menu.reset"), action: #selector(Tools.reset), keyEquivalent: "r")))
                $0.autoenablesItems = false
                return $0
            } (NSMenu(title: .local("Menu.project")))
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        addItem({
            $0.submenu = {
                $0.addItem(withTitle: .local("Menu.minimize"), action:
                    #selector(Home.performMiniaturize(_:)), keyEquivalent: "m")
                $0.addItem(withTitle: .local("Menu.zoom"), action: #selector(Home.performZoom(_:)), keyEquivalent: "p")
                $0.addItem(NSMenuItem.separator())
                $0.addItem(withTitle: .local("Menu.bringAllToFront"), action:
                    #selector(App.arrangeInFront(_:)), keyEquivalent: "")
                $0.autoenablesItems = false
                return $0
            } (NSMenu(title: .local("Menu.window")))
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
        
        addItem({
            $0.submenu = {
                $0.addItem({
                    help = $0
                    return $0
                } (NSMenuItem(title: .local("Menu.showHelp"), action: #selector(App.showHelp(_:)), keyEquivalent: "/")))
                $0.autoenablesItems = false
                return $0
            } (NSMenu(title: .local("Menu.help")))
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
    }
    
    required init(coder: NSCoder) { fatalError() }
    
    func validate() {
        if Sheet.presented == nil {
            preferences.isEnabled = true
            directory.isEnabled = true
            help.isEnabled = true
            refresh.isEnabled = App.repository != nil
            log.isEnabled = App.repository != nil
            commit.isEnabled = App.repository != nil
            reset.isEnabled = App.repository != nil
        } else {
            preferences.isEnabled = false
            directory.isEnabled = false
            refresh.isEnabled = false
            log.isEnabled = false
            commit.isEnabled = false
            reset.isEnabled = false
            help.isEnabled = false
        }
        if #available(OSX 10.12.2, *) {
            App.home.touchBar = nil
        }
    }
}
