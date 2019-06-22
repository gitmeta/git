import Git
import AppKit
import StoreKit

final class Market: NSWindow, SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private final class Item: NSView {
        let product: SKProduct
        private(set) weak var button: Button.Text!
        private(set) weak var label: Label!
        private(set) weak var purchased: Label!
        private(set) weak var price: Label!
        private(set) weak var image: NSImageView!
        
        init(_ product: SKProduct) {
            self.product = product
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let image = NSImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.imageScaling = .scaleNone
            addSubview(image)
            self.image = image
            
            let label = Label()
            label.textColor = .white
            addSubview(label)
            self.label = label
            
            let price = Label()
            price.textColor = .white
            price.font = .systemFont(ofSize: 16, weight: .medium)
            addSubview(price)
            self.price = price
            
            let purchased = Label(.local("Market.purchased"))
            purchased.textColor = .halo
            purchased.font = .systemFont(ofSize: 16, weight: .medium)
            purchased.isHidden = true
            addSubview(purchased)
            self.purchased = purchased
            
            let button = Button.Text(nil, action: nil)
            button.label.stringValue = .local("Market.purchase")
            button.label.font = .systemFont(ofSize: 11, weight: .medium)
            button.label.textColor = .black
            button.wantsLayer = true
            button.layer!.cornerRadius = 4
            button.layer!.backgroundColor = NSColor.halo.cgColor
            addSubview(button)
            self.button = button
            
            image.topAnchor.constraint(equalTo: topAnchor).isActive = true
            image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            image.widthAnchor.constraint(equalToConstant: 60).isActive = true
            image.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            label.topAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            
            price.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 50).isActive = true
            price.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            
            purchased.rightAnchor.constraint(equalTo: price.rightAnchor).isActive = true
            purchased.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
            
            button.topAnchor.constraint(equalTo: price.bottomAnchor, constant: 10).isActive = true
            button.rightAnchor.constraint(equalTo: price.rightAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
            button.widthAnchor.constraint(equalToConstant: 90).isActive = true
            button.heightAnchor.constraint(equalToConstant: 22).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private weak var request: SKProductsRequest?
    private weak var image: NSImageView!
    private weak var list: NSScrollView!
    private weak var restore: Button.Text!
    private weak var bottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; bottom.isActive = true } }
    private var products = [SKProduct]() { didSet { DispatchQueue.main.async { [weak self] in self?.refresh() } } }
    private let formatter = NumberFormatter()
    
    init() {
        super.init(contentRect: NSRect(
            x: app.home.frame.minX + 50, y: app.home.frame.maxY - 450, width: 400, height: 400),
                   styleMask: [.closable, .fullSizeContentView, .miniaturizable, .titled, .unifiedTitleAndToolbar],
                   backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .shade
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        toolbar = NSToolbar(identifier: "")
        toolbar!.showsBaselineSeparator = false
        
        formatter.numberStyle = .currencyISOCode
        
        let title = Label(.local("Market.title"))
        title.font = .systemFont(ofSize: 12, weight: .bold)
        title.textColor = .halo
        contentView!.addSubview(title)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        contentView!.addSubview(border)
        
        let list = NSScrollView()
        list.translatesAutoresizingMaskIntoConstraints = false
        list.drawsBackground = false
        list.hasVerticalScroller = true
        list.verticalScroller!.controlSize = .mini
        list.horizontalScrollElasticity = .none
        list.verticalScrollElasticity = .allowed
        list.documentView = Flipped()
        list.documentView!.translatesAutoresizingMaskIntoConstraints = false
        list.documentView!.topAnchor.constraint(equalTo: list.topAnchor).isActive = true
        list.documentView!.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
        list.documentView!.rightAnchor.constraint(equalTo: list.rightAnchor).isActive = true
        list.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: list.bottomAnchor).isActive = true
        contentView!.addSubview(list)
        self.list = list
        
        let restore = Button.Text(self, action: #selector(restoring))
        restore.label.stringValue = .local("Market.restore")
        restore.label.font = .systemFont(ofSize: 11, weight: .medium)
        restore.label.textColor = .black
        restore.wantsLayer = true
        restore.layer!.cornerRadius = 4
        restore.layer!.backgroundColor = NSColor.halo.cgColor
        contentView!.addSubview(restore)
        self.restore = restore
        
        let image = NSImageView()
        image.image = NSImage(named: "loading")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.imageScaling = .scaleNone
        contentView!.addSubview(image)
        self.image = image
        
        title.centerYAnchor.constraint(equalTo: restore.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 80).isActive = true
        
        border.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 39).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        list.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -1).isActive = true
        list.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 2).isActive = true
        list.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -2).isActive = true
        
        image.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 60).isActive = true
        image.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        restore.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -10).isActive = true
        restore.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 20).isActive = true
        restore.widthAnchor.constraint(equalToConstant: 90).isActive = true
        restore.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        show("loading")
        SKPaymentQueue.default().add(self)
        
        let request = SKProductsRequest(productIdentifiers: Set(Session.Purchase.allCases.map({ "git.mac." + $0.rawValue })))
        request.delegate = self
        self.request = request
        request.start()
    }
    
    override func close() {
        SKPaymentQueue.default().remove(self)
        super.close()
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 13:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                close()
            } else {
                super.keyDown(with: with)
            }
        case 53: close()
        default: super.keyDown(with: with)
        }
    }
    
    func productsRequest(_: SKProductsRequest, didReceive: SKProductsResponse) { products = didReceive.products }
    func paymentQueue(_: SKPaymentQueue, updatedTransactions: [SKPaymentTransaction]) { update(updatedTransactions) }
    func paymentQueue(_: SKPaymentQueue, removedTransactions: [SKPaymentTransaction]) { update(removedTransactions) }
    func paymentQueueRestoreCompletedTransactionsFinished(_: SKPaymentQueue) { DispatchQueue.main.async { [weak self] in self?.refresh() } }
    func request(_: SKRequest, didFailWithError: Error) { DispatchQueue.main.async { [weak self] in self?.error(didFailWithError) } }
    func paymentQueue(_: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error) { DispatchQueue.main.async { [weak self] in self?.error(restoreCompletedTransactionsFailedWithError) } }
    
    private func update(_ transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            switch $0.transactionState {
            case .failed: SKPaymentQueue.default().finishTransaction($0)
            case.restored: Hub.session.purchase($0.payment.productIdentifier)
            case .purchased:
                Hub.session.purchase($0.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction($0)
            default: break
            }
        }
        if !products.isEmpty {
            DispatchQueue.main.async { [weak self] in self?.refresh() }
        }
    }
    
    private func refresh() {
        image.isHidden = true
        restore.isHidden = false
        list.documentView!.subviews.forEach { $0.removeFromSuperview() }
        var bottom = list.documentView!.topAnchor
        products.forEach { product in
            let name = product.productIdentifier.components(separatedBy: ".").last!
            let item = Item(product)
            formatter.locale = product.priceLocale
            item.price.stringValue = formatter.string(from: product.price) ?? ""
            item.image.image = NSImage(named: name)
            item.label.attributedStringValue = {
                $0.append(NSAttributedString(string: product.localizedTitle, attributes: [.font: NSFont.systemFont(ofSize: 18, weight: .bold)]))
                $0.append(NSAttributedString(string: .local("Market.\(name)"), attributes: [.font: NSFont.systemFont(ofSize: 16, weight: .light)]))
                return $0
            } (NSMutableAttributedString())
            item.button.target = self
            item.button.action = #selector(purchase(_:))
            if Hub.session.purchase.contains(where: { $0 == Session.Purchase(rawValue: name) }) {
                item.purchased.isHidden = false
                item.button.isHidden = true
            }
            list.documentView!.addSubview(item)
            
            item.topAnchor.constraint(equalTo: bottom).isActive = true
            item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            item.rightAnchor.constraint(equalTo: list.rightAnchor).isActive = true
            bottom = item.bottomAnchor
        }
        self.bottom = list.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: bottom)
    }
    
    private func error(_ error: Error) {
        app.alert(.local("Alert.error"), message: error.localizedDescription)
        show("error")
    }
    
    private func show(_ image: String) {
        self.image.image = NSImage(named: image)
        self.image.isHidden = false
        restore.isHidden = true
        list.documentView!.subviews.forEach { $0.removeFromSuperview() }
    }
    
    @objc private func restoring() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        show("loading")
    }
    
    @objc private func purchase(_ button: Button.Text) {
        show("loading")
        SKPaymentQueue.default().add(SKPayment(product: (button.superview as! Item).product))
    }
}
