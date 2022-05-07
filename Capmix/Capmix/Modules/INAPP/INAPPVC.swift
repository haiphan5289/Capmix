
//
//  
//  INAPPVC.swift
//  Capmix
//
//  Created by haiphan on 04/05/2022.
//
//
import UIKit
import RxCocoa
import RxSwift
import EasyBaseCodes

class INAPPVC: UIViewController {
    
    // Add here outlets
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var lbSelect: UILabel!
    @IBOutlet weak var lbWeek: UILabel!
    
    // Add here your view model
    private var listProductModel: [SKProductModel] = []
    private var viewModel: INAPPVM = INAPPVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension INAPPVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white,
                                                    NSAttributedString.Key.font: UIFont.mySystemFont(ofSize: 17)], for: .selected)
        
        // color of other options
        self.segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black,
                                                    NSAttributedString.Key.font: UIFont.mySystemFont(ofSize: 17)], for: .normal)
        self.listProductModel = CampixManage.shared.listRawSKProduct()
        self.segmentControl.selectedSegmentIndex = PaymentInApp.month.rawValue
        self.lbWeek.text = "$\(self.listProductModel[1].price)/\(self.listProductModel[1].productID) - 3 days free trial"
        
        InAppPerchaseManager.shared.requestProducts { [weak self] isSuccess, skProducts in
            guard let wSelf = self else { return }
            if isSuccess, let sk = skProducts, sk.count >= 3 {
                sk.forEach { item in
                    let m = SKProductModel(productID: item.productIdentifier, price: item.price)
                    wSelf.listProductModel.append(m)
                }
                wSelf.lbWeek.text = "$\(wSelf.listProductModel[1].price)/\(wSelf.listProductModel[1].productID) - 3 days free trial"
            } else {
                wSelf.listProductModel = CampixManage.shared.listRawSKProduct()
            }
        }
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.segmentControl.rx.selectedSegmentIndex.bind { [weak self] index in
            guard let wSelf = self else { return }
            wSelf.lbSelect.text = "$\(wSelf.listProductModel[index].price)/\(wSelf.listProductModel[index].productID)"
        }.disposed(by: self.disposeBag)
    }
}
