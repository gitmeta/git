import AppKit

final class About: Window {
    init() {
        super.init(200, 200)
        border.isHidden = true
        
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        image.image = NSImage(named: "logo")
        contentView!.addSubview(image)
        
        let label = Label(.key("About.label"))
        label.textColor = .halo
        label.font = .bold(20)
        contentView!.addSubview(label)
        
        let version = Label((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "")
        version.textColor = .halo
        version.font = .light(12)
        contentView!.addSubview(version)
        
        image.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor, constant: -25).isActive = true
        image.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: contentView!.centerYAnchor, constant: 20).isActive = true
        
        version.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        version.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
    }
}
