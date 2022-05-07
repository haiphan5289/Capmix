//
//  ArrayExxtension.swift
//  Note
//
//  Created by haiphan on 06/10/2021.
//

import Foundation

public extension Array {
    
    func hasIndex(index: Int) -> Int? {
        for i in 0...self.count - 1 {
            if index == i {
                return i
            }
        }
        return nil
    }
}

public struct SKProductModel {
    public let productID: String
    public let price: NSDecimalNumber
    public init(productID: String, price: NSDecimalNumber) {
        self.productID = productID
        self.price = price
    }
    
    public func getTextPrice() -> String {
        return "$\(self.price.roundTo())"
    }
}
