import Git
import UIKit
import StoreKit

final class Market: UIView, SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private class Item: UIView {
        let product: SKProduct
        private(set) weak var button: Button.Yes!
        private(set) weak var label: UILabel!
        private(set) weak var purchased: UILabel!
        private(set) weak var price: UILabel!
        private(set) weak var image: UIImageView!
        
        init(_ product: SKProduct) {
            self.product = product
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.clipsToBounds = true
            image.contentMode = .center
            addSubview(image)
            self.image = image
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textColor = .white
            addSubview(label)
            self.label = label
            
            let price = UILabel()
            price.translatesAutoresizingMaskIntoConstraints = false
            price.textColor = .white
            price.font = .systemFont(ofSize: 16, weight: .medium)
            addSubview(price)
            self.price = price
            
            let purchased = UILabel()
            purchased.text = .local("Market.purchased")
            purchased.translatesAutoresizingMaskIntoConstraints = false
            purchased.textColor = .white
            purchased.font = .systemFont(ofSize: 14, weight: .medium)
            purchased.isHidden = true
            addSubview(purchased)
            self.purchased = purchased
            
            let button = Button.Yes(.local("Market.purchase"))
            addSubview(button)
            self.button = button
            
            image.topAnchor.constraint(equalTo: topAnchor).isActive = true
            image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            image.widthAnchor.constraint(equalToConstant: 60).isActive = true
            image.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            label.topAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            
            price.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 25).isActive = true
            price.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            
            purchased.rightAnchor.constraint(equalTo: price.rightAnchor).isActive = true
            purchased.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
            
            button.topAnchor.constraint(equalTo: price.bottomAnchor, constant: 10).isActive = true
            button.rightAnchor.constraint(equalTo: price.rightAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private weak var request: SKProductsRequest?
    private weak var image: UIImageView!
    private weak var list: UIScrollView!
    private weak var restore: Button.Yes!
    private weak var bottom: NSLayoutConstraint! { didSet { oldValue?.isActive = false; bottom.isActive = true } }
    private var products = [SKProduct]() { didSet { refresh() } }
    private let formatter = NumberFormatter()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        formatter.numberStyle = .currencyISOCode
        
        let border = UIView()
        border.isUserInteractionEnabled = true
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = .halo
        addSubview(border)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 12, weight: .bold)
        title.textColor = .halo
        title.text = .local("Market.title")
        addSubview(title)
        
        let restore = Button.Yes(.local("Market.restore"))
        restore.addTarget(self, action: #selector(restoring), for: .touchUpInside)
        addSubview(restore)
        self.restore = restore
        
        let image = UIImageView(image: UIImage(named: "loading"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        addSubview(image)
        self.image = image
        
        let list = UIScrollView()
        list.translatesAutoresizingMaskIntoConstraints = false
        list.alwaysBounceVertical = true
        addSubview(list)
        self.list = list
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        title.centerYAnchor.constraint(equalTo: topAnchor, constant: 27).isActive = true
        
        list.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        list.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.bottomAnchor.constraint(equalTo: topAnchor, constant: 55).isActive = true
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 38).isActive = true
        image.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        restore.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        restore.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func start() {
        show("loading")
        SKPaymentQueue.default().remove(self)
        SKPaymentQueue.default().add(self)
        self.request?.cancel()
    
        let request = SKProductsRequest(productIdentifiers: Set(Session.Purchase.allCases.map({ "git.ios." + $0.rawValue })))
        request.delegate = self
        self.request = request
        request.start()
    }
    
    func productsRequest(_: SKProductsRequest, didReceive: SKProductsResponse) { products = didReceive.products }
    func paymentQueue(_: SKPaymentQueue, updatedTransactions: [SKPaymentTransaction]) { update(updatedTransactions) }
    func paymentQueue(_: SKPaymentQueue, removedTransactions: [SKPaymentTransaction]) { update(removedTransactions) }
    func paymentQueueRestoreCompletedTransactionsFinished(_: SKPaymentQueue) { refresh() }
    func request(_: SKRequest, didFailWithError: Error) { error(didFailWithError) }
    func paymentQueue(_: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error) { error(restoreCompletedTransactionsFailedWithError) }
    
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
            refresh()
        }
    }
    
    private func refresh() {
        image.isHidden = true
        restore.isHidden = false
        list.subviews.forEach { $0.removeFromSuperview() }
        var bottom = list.topAnchor
        products.forEach { product in
            let name = product.productIdentifier.components(separatedBy: ".").last!
            let item = Item(product)
            formatter.locale = product.priceLocale
            item.price.text = formatter.string(from: product.price)
            item.image.image = UIImage(named: name)
            item.label.attributedText = {
                $0.append(NSAttributedString(string: product.localizedTitle, attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold)]))
                $0.append(NSAttributedString(string: .local("Market.\(name)"), attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .light)]))
                return $0
            } (NSMutableAttributedString())
            item.button.addTarget(self, action: #selector(purchase(_:)), for: .touchUpInside)
            if Hub.session.purchase.contains(where: { $0 == Session.Purchase(rawValue: name) }) {
                item.purchased.isHidden = false
                item.button.isHidden = true
            }
            list.addSubview(item)
            
            item.leftAnchor.constraint(equalTo: list.leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            item.topAnchor.constraint(equalTo: bottom).isActive = true
            bottom = item.bottomAnchor
        }
        self.bottom = list.bottomAnchor.constraint(greaterThanOrEqualTo: bottom)
    }
    
    private func error(_ error: Error) {
        app.alert(.local("Alert.error"), message: error.localizedDescription)
        show("error")
    }
    
    private func show(_ image: String) {
        self.image.image = UIImage(named: image)
        self.image.isHidden = false
        restore.isHidden = true
        list.subviews.forEach { $0.removeFromSuperview() }
    }
    
    @objc private func restoring() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        show("loading")
    }
    
    @objc private func purchase(_ button: Button.Yes) {
        show("loading")
        SKPaymentQueue.default().add(SKPayment(product: (button.superview as! Item).product))
    }
}
