
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
import EasyBaseAudio
import SVProgressHUD
import SwiftyStoreKit

protocol INAPPDelegate {
    func dismiss()
}

class INAPPVC: UIViewController {
    
    enum Action: Int, CaseIterable {
        case restore, close, term, privacy, sub
    }
    
    enum openfrom {
        case welcome, home
    }
     
    var delegate: INAPPDelegate?
    var openfrom: openfrom = .home
    
    // Add here outlets
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var lbSelect: UILabel!
    @IBOutlet weak var lbWeek: UILabel!
    @IBOutlet var bts: [UIButton]!
    @IBOutlet weak var lbExport: UILabel!
    @IBOutlet var lbs: [UILabel]!
    
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
        self.lbWeek.text = "$\(self.listProductModel[1].price)/\(PaymentInApp.month.text) - 3 days free trial"
        
        InAppPerchaseManager.shared.requestProducts { [weak self] isSuccess, skProducts in
            guard let wSelf = self else { return }
            if isSuccess, let sk = skProducts, sk.count >= 3 {
                sk.forEach { item in
                    let m = SKProductModel(productID: item.productIdentifier, price: item.price)
                    wSelf.listProductModel.append(m)
                }
                wSelf.lbWeek.text = "$\(wSelf.listProductModel[1].price)/\(PaymentInApp.month.text) - 3 days free trial"
            } else {
                wSelf.listProductModel = CampixManage.shared.listRawSKProduct()
            }
        }
        
        if self.openfrom == .home {
            self.lbs.forEach { lb in
                lb.isHidden = true
            }
        } else {
            self.lbExport.isHidden = true
        }
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.segmentControl.rx.selectedSegmentIndex.bind { [weak self] index in
            guard let wSelf = self, let productCode = PaymentInApp(rawValue: index) else { return }
            wSelf.lbSelect.text = "$\(wSelf.listProductModel[index].price)/\(productCode.text)"
        }.disposed(by: self.disposeBag)
        
        Action.allCases.forEach { [weak self] action in
            guard let wSelf = self else { return }
            let bt = wSelf.bts[action.rawValue]
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                switch action {
                case .close:
                    wSelf.dismiss(animated: true, completion: nil)
                case .term:
                    AudioManage.shared.openLink(link: ConstantApp.shared.linkTerm)
                case .privacy:
                    AudioManage.shared.openLink(link: ConstantApp.shared.linkPrivacy)
                case .restore:
                    wSelf.restoreInApp()
                case .sub:
                    let index = wSelf.segmentControl.selectedSegmentIndex
                    wSelf.sub(wSelf.listProductModel[index].productID)
                    
                }
            }.disposed(by: wSelf.disposeBag)
        }
    }
}
extension INAPPVC {
    
    func restoreInApp() {
        if (InAppPerchaseManager.shared.canMakePurchase()) {
            InAppPerchaseManager.shared.restoreCompletedTransactions()
        }
    }
    
    //Action 3 nút sẽ call
//    func weekly() {
//        self.sub(.weekly)
//    }
//
//    func monthly() {
//        self.sub(.monthly)
//    }
//
//    func yearly() {
//        self.sub(.yearly)
//    }
//
//    func dayfree() {
//        self.sub(.dayfree)
//    }
    
    func sub(_ model: String) {
        self.subscriptionAction(productId: model)
    }
    
    func subscriptionAction(productId: String) {
        //self.showLoading()
        SVProgressHUD.show()
        SwiftyStoreKit.purchaseProduct(productId, atomically: true) { [weak self] (result) in
            guard let `self` = self else { return }
            //self.hideLoading()
            switch result {
            case .success(_):
                Configuration.joinPremiumUser(join: true)
                self.showAlert(title: "Successful", message: "Successful") { [weak self] in
                    guard let wSelf = self else { return }
                    wSelf.dismiss(animated: true, completion: { [weak self] in
                        guard let wSelf = self else { return }
                        wSelf.delegate?.dismiss()
                    })
                    SVProgressHUD.dismiss()
                }
            case .error(_):
                self.showAlert(title: "Cannot subcribe", message: "Cannot subcribe")
                SVProgressHUD.dismiss()
            }
        }
        
    }
}
