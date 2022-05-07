//
//  CampixManage.swift
//  Capmix
//
//  Created by haiphan on 10/04/2022.
//

import Foundation
import EasyBaseAudio
import EasyBaseCodes

final class CampixManage {
        
    static var shared = CampixManage()
    
    //MARK: DEFAULT VALUE INAPP
    func listRawSKProduct() -> [SKProductModel] {
        var list: [SKProductModel] = []
        let w = SKProductModel(productID: ProductID.weekly.textValue, price: 0.99)
        let m = SKProductModel(productID: ProductID.monthly.textValue, price: 1.99)
        let y = SKProductModel(productID: ProductID.yearly.textValue, price: 9.99)
        list.append(w)
        list.append(m)
        list.append(y)
        return list
    }
    
}
