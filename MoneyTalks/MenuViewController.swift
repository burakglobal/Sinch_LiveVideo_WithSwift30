
import UIKit
import SwiftyJSON
import StoreKit

class MenuViewController: UITableViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    let COINS_PRODUCT_BUY10 = "MONEYTALKS.buy10"
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var coins = UserDefaults.standard.integer(forKey: "coins")
    
    @IBOutlet weak var girisName: UILabel!
    
    @IBOutlet weak var girisPicture: UIImageView!
    
    @IBOutlet weak var currentcredit: UILabel!
    @IBOutlet weak var imageContainer: UIView!
    let settings = GlobalViewController()
    @IBOutlet weak var mySwitch: UISwitch!
    
    @IBOutlet var menuTableView: UITableView! {
        didSet{
            menuTableView.delegate = self
            menuTableView.bounces = false
        }
    }
    
  
    struct Notifications {
        static let MainSelected = "MainSelected"
        static let RedSelected = "RedSelected"
        static let GreenSelected = "GreenSelected"
        static let SearchSelected = "SearchSelected"
        static let LogoutSelected = "LogoutSelected"
        static let CallSelected = "CallSelected"
        static let howSelected = "howSelected"
    }
    
    struct Login {
        let girisYapildimi = 0
    }
    
    override func viewDidLoad() {
        let backgroundImage = UIImage(named: "bg")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(creditupdate), name: NSNotification.Name(rawValue: "credit"), object: nil)
        girisName.text = "Welcome, " + settings.getDefaults(isim: "facebookName")
        girisPicture.downloadedFrom(link: self.settings.getDefaults(isim: "picture"))
        girisPicture.setRounded()
        imageContainer.layer.cornerRadius = 5
        girisPicture.layer.borderWidth = 1
        girisPicture.layer.borderColor = UIColor.gray.cgColor
        girisPicture.contentMode = UIViewContentMode.scaleAspectFill
        var swiftsettings = settings.getDefaults(isim: "getcalls")
        if (swiftsettings=="0") {
             mySwitch.setOn(false, animated: false)
        }
        else{
             mySwitch.setOn(true, animated: false)
        }
        fetchAvailableProducts()
        currentcredit.text = "$" + settings.getDefaults(isim: "credit")
        
    } 
    
    func creditupdate() {
        //settings.getjustcredit()
        currentcredit.text = "$" + settings.getDefaults(isim: "credit")
    }
    
    
    @IBAction func mySwitchValueChanged(_ sender: Any) {
        let value = mySwitch.isOn
        print(value)
        if value==true {
            settings.updateswitch(status: "1")
            settings.saveDefaults(deger: "1", isim: "getcalls")
        }
        else
        {
            settings.updateswitch(status: "0")
            settings.saveDefaults(deger: "0", isim: "getcalls")
        }
    }
     func restorepurchase()
     {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()

    }

    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as? NSError {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                print("Transaction Error: \(transaction.error?.localizedDescription)")
                
                UIAlertView(title: "MoneyTalks",
                            message: "Transaction Error: \(transaction.error?.localizedDescription)",
                            delegate: nil,
                            cancelButtonTitle: "OK").show()

                
                
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
 
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                    
                case .purchased:
                   
            
                        settings.updatecredit(status: 1.0, kac: "1")
                        
                        UIAlertView(title: "MoneyTalks",
                                    message: "You've successfully added 10 Minutes! Lets Talk!",
                                    delegate: nil,
                                    cancelButtonTitle: "OK").show()
                        
                        
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        
                    break
                    
                case .failed:
                    print("failed")
                    fail(transaction: transaction as! SKPaymentTransaction)

                    break
                case .restored:
                    
                    UIAlertView(title: "MoneyTalks",
                                message: "Pending Transaction restored!",
                                delegate: nil,
                                cancelButtonTitle: "OK").show()
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                    
                case .deferred:
                    break
                case .purchasing:
                    break
                    
                default: break
                }}}
    }
    @IBAction func addcredit(_ sender: Any) {
        print("add credit")
         purchaseMyProduct(product: iapProducts[0])
    }
    
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if (response.products.count > 0) {
            iapProducts = response.products
            
            // 1st IAP Product (Consumable) ------------------------------------
            let firstProduct = response.products[0] as SKProduct
            
            // Get its price from iTunes Connect
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = firstProduct.priceLocale
            let price1Str = numberFormatter.string(from: firstProduct.price)
            
            // Show its description
           print(firstProduct.localizedDescription + "\nfor just \(price1Str!)")
            // ------------------------------------------------
            
            
            
            // 2nd IAP Product (Non-Consumable) ------------------------------
          
            // ------------------------------------
        }
    }
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
            
            
            // IAP Purchases dsabled on the Device
        } else {
            UIAlertView(title: "MoneyTalks",
                        message: "Purchases are disabled in your device!",
                        delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    func fetchAvailableProducts()  {
        
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects:
            COINS_PRODUCT_BUY10
        )
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        UIAlertView(title: "MoneyTalks",
                    message: "You've successfully restored your purchase!",
                    delegate: nil, cancelButtonTitle: "OK").show()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = indexPath.item
        let center = NotificationCenter.default
        
        switch item {
        case 0:
            addcredit(self)
        case 1:
            center.post(Notification(name: Notification.Name(rawValue: Notifications.MainSelected), object: self))

        case 2:
            center.post(Notification(name: Notification.Name(rawValue: Notifications.RedSelected), object: self))
        case 3:
            center.post(Notification(name: Notification.Name(rawValue: Notifications.GreenSelected), object: self))
        case 4:
            center.post(Notification(name: Notification.Name(rawValue: Notifications.SearchSelected), object: self))
        case 5:
            center.post(Notification(name: Notification.Name(rawValue: Notifications.howSelected), object: self))
        case 6:
          
            let lvc = LoginViewController()
            lvc.logout()
                     
        default:
            print("Unrecognized menu index")
            return
        }
       
       

    }
    func menuhid(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
        self.present(vc, animated: false, completion: nil)
        vc.hideMenu()
    
    }
   
    
    
    
    
}

