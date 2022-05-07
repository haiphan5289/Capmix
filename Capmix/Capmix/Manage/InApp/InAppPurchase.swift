//
//  InAppPurchase.swift
//  DemoInappPurchase
//
//  Created by ThanhPham on 2/27/17.
//  Copyright © 2017 Sanis.Inc. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

enum PaymentInApp: Int, CaseIterable {
    case week
    case month
    case year
}

enum ProductID: String, CaseIterable {
    case weekly = "com.recorderweek1"
    case monthly = "com.recordermonth1"
    case yearly = "com.recorderyear1"
    case dayfree = "3Day_Trial"

    var text: String {
        switch self {
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        default:
            return "Trial"
        }
    }
    
    var textValue: String {
        switch self {
        case .weekly:
            return "Week"
        case .monthly:
            return "Month"
        case .yearly:
            return "Year"
        default:
            return "Trial"
        }
    }
    
//    var valuePrenium: INAPPVC.InAppSegment {
//        switch self {
//        case .weekly: return INAPPVC.InAppSegment.week
//        case .monthly: return INAPPVC.InAppSegment.month
//        case .yearly: return INAPPVC.InAppSegment.year
//        default: return INAPPVC.InAppSegment.year
//        }
//    }
    
}
let kIAPPurchasedNotification = "IAPPurchasedNotification"
let kIAPFailedNotification = "IAPFailedNotification"

open class InAppPerchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static var shared = InAppPerchaseManager()
    var productIdentifiers: Set<String>?
    var productsRequest: SKProductsRequest?
    
    var completionHandler: ((_ success: Bool, _ products: [SKProduct]?) -> Void)?
    
    var purchasedProductIdentifiers = Set<String>()
    var paymentCode = ""
    fileprivate var hasValidReceipt = false
    
    public override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        productIdentifiers = Set<String>()
    }
    
    /**
     Add a single product ID
     
     - Parameter id: Product ID in string format
     */
    open func addProductId(_ id: String) {
        productIdentifiers?.insert(id)
    }
    
    /**
     Add multiple product IDs
     
     - Parameter ids: Set of product ID strings you wish to add
     */
    open func addProductIds(_ ids: Set<String>) {
        productIdentifiers?.formUnion(ids)
    }
    
    
    /**
     Load purchased products
     
     - Parameter checkWithApple: True if you want to validate the purchase receipt with Apple servers
     */
    open func loadPurchasedProducts(_ checkWithApple: Bool, completion: ((_ valid: Bool) -> Void)?) {
        
        if let productIdentifiers = productIdentifiers {
            
            for productIdentifier in productIdentifiers {
                
                let isPurchased = UserDefaults.standard.bool(forKey: productIdentifier)
                
                if isPurchased {
                    purchasedProductIdentifiers.insert(productIdentifier)
                    print("Purchased: \(productIdentifier)")
                } else {
                    print("Not purchased: \(productIdentifier)")
                }
                
            }
            
            if checkWithApple {
                print("Checking with Apple...")
                if let completion = completion {
                    validateReceipt(false, completion: completion)
                } else {
                    validateReceipt(false) { (valid) -> Void in
                        if valid { print("Receipt is Valid!") } else { print("BEWARE! Reciept is not Valid!!!") }
                    }
                }
            }
            
        }
        
    }
    
    fileprivate func validateReceipt(_ sandbox: Bool, completion:@escaping (_ valid: Bool) -> Void) {
        
        let url = Bundle.main.appStoreReceiptURL
        let receipt = try? Data(contentsOf: url!)
        
        if let r = receipt {
            self.paymentCode = r.base64EncodedString(options: NSData.Base64EncodingOptions())
            completion(true)
        } else {
            hasValidReceipt = false
            completion(false)
        }
        
    }
    
    fileprivate func checkStatus(_ data: Data?, completion:@escaping (_ valid: Bool) -> Void) {

        do {
            if let data = data, let jsonResponse: AnyObject = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject? {
            
                if let status = jsonResponse["status"] as? Int {
                    if status == 0 {
                        print("Status: VALID")
                        hasValidReceipt = true
                        completion(true)
                    } else if status == 21007 {
                        print("Status: CHECK WITH SANDBOX")
                        validateReceipt(true, completion: completion)
                    } else {
                        print("Status: INVALID")
                        hasValidReceipt = false
                        completion(false)
                    }
                }
                
            }
        }
    }
    
    /**
     Request products from Apple
     */
    open func requestProducts(_ completionHandler: @escaping (_ success:Bool, _ products:[SKProduct]?) -> Void) {
        self.completionHandler = completionHandler
        
        print("Requesting Products")
        
        if let productIdentifiers = productIdentifiers {
            productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            productsRequest!.delegate = self
            productsRequest!.start()
        } else {
            print("No productIdentifiers")
            completionHandler(false, nil)
        }
    }
    
    /**
     Check if the product with identifier is already purchased
     */
    open func productPurchased(_ productIdentifier: String) -> (isPurchased: Bool, hasValidReceipt: Bool) {
        let purchased = purchasedProductIdentifiers.contains(productIdentifier)
        return (purchased, hasValidReceipt)
    }
    
    /**
     Begin to start restoration of already purchased products
     */
    open func restoreCompletedTransactions() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    /**
     Initiate purchase for the product
     
     - Parameter product: The product you want to purchase
     */
    open func purchaseProduct(_ product: SKProduct) {
        print("Purchasing product: \(product.productIdentifier)")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    //MARK: - Transactions
    
    fileprivate func completeTransaction(_ transaction: SKPaymentTransaction) {
        print("Complete Transaction...")
        
       // provideContentForProductIdentifier(transaction.transactionIdentifier)
        print("transactionIdentifier: \(transaction.transactionIdentifier)\n payment: \(transaction.payment)")
        guard let transactionIdentifier: String =  transaction.transactionIdentifier as? String else {
            return
        }
        
        self.validateReceipt(true) { (success) in
            if success {
                NotificationCenter.default.post(name: Notification.Name(rawValue: kIAPPurchasedNotification), object: transaction.transactionIdentifier, userInfo: ["transactionIdentifier": transaction.transactionIdentifier ?? "",
                                                                                                                                                                    "paymentCode":"\(transaction.payment.productIdentifier)"])
                
                
                SKPaymentQueue.default().finishTransaction(transaction)
            }else {
                SKPaymentQueue.default().finishTransaction(transaction)
                NotificationCenter.default.post(name: Notification.Name(rawValue: kIAPFailedNotification), object: nil, userInfo: nil)

            }
           
        }
      
    }
    
    fileprivate func restoreTransaction(_ transaction: SKPaymentTransaction) {
        print("Restore Transaction...")
        
        provideContentForProductIdentifier(transaction.original!.transactionIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func failedTransaction(_ transaction: SKPaymentTransaction) {
        print("Failed Transaction...")
        
        if let error = transaction.error! as? SKError {
            if (error.code != .paymentCancelled) {
                print("Transaction error \(transaction.error!._code): \(transaction.error!.localizedDescription)")
                NotificationCenter.default.post(name: Notification.Name(rawValue: kIAPFailedNotification), object: nil, userInfo: nil)
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        
    }
    
    fileprivate func provideContentForProductIdentifier(_ productIdentifier: String!) {
        purchasedProductIdentifiers.insert(productIdentifier)
        
        UserDefaults.standard.set(true, forKey: productIdentifier)
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kIAPPurchasedNotification), object: productIdentifier, userInfo: nil)
    }
    
    // MARK: - Delegate Implementations
    
    open func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction:AnyObject in transactions
        {
            if let trans = transaction as? SKPaymentTransaction
            {
                switch trans.transactionState {
                case .purchased:
                    completeTransaction(trans)
                    break
                case .failed:
                    failedTransaction(trans)
                    break
                case .restored:
                    restoreTransaction(trans)
                    break
                default:
                    break
                }
            }
        }
    }
    
    open func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        print("Loaded product list!")
        
        productsRequest = nil
        
        let skProducts = response.products
        
        for skProduct in skProducts  {
            print("Found product: \(skProduct.productIdentifier) - \(skProduct.localizedTitle) - \(skProduct.price)")
        }
        
        if let completionHandler = completionHandler {
            completionHandler(true, skProducts)
        }
        
        completionHandler = nil
        
    }
    
    open func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products!")
        productsRequest = nil
        if let completionHandler = completionHandler {
            completionHandler(false, nil)
        }
        completionHandler = nil
    }
    
    //MARK: - Helpers
    
    /**
     Check if the user can make purchase
     */
    open func canMakePurchase() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
}
