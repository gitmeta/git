import Git
import UIKit
import StoreKit

final class Market: UIView, SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private weak var image: UIImageView!
    private weak var request: SKProductsRequest?
    private var products = [SKProduct]()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImageView(image: UIImage(named: "loading"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        addSubview(image)
        self.image = image
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 38).isActive = true
        image.heightAnchor.constraint(equalToConstant: 38).isActive = true
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
    
    func paymentQueue(_: SKPaymentQueue, updatedTransactions: [SKPaymentTransaction]) { update(updatedTransactions) }
    func paymentQueue(_: SKPaymentQueue, removedTransactions: [SKPaymentTransaction]) { update(removedTransactions) }
    func paymentQueueRestoreCompletedTransactionsFinished(_: SKPaymentQueue) { refresh() }
    func request(_: SKRequest, didFailWithError: Error) { error(didFailWithError) }
    func paymentQueue(_: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error) { error(restoreCompletedTransactionsFailedWithError) }
    
    func productsRequest(_: SKProductsRequest, didReceive: SKProductsResponse) {
        products = didReceive.products
        refresh()
    }
    
    private func update(_ transactions: [SKPaymentTransaction]) {
        transactions.filter({ $0.transactionState == .failed || $0.transactionState == .purchased })
            .forEach { SKPaymentQueue.default().finishTransaction($0) }
        refresh()
    }
    
    private func refresh() {
        print(products)
    }
    
    private func error(_ error: Error) {
        app.alert(.local("Alert.error"), message: error.localizedDescription)
        show("error")
    }
    
    private func show(_ image: String) {
        self.image.image = UIImage(named: image)
        self.image.isHidden = false
    }
}
