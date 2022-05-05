
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

class INAPPVC: UIViewController {
    
    // Add here outlets
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // Add here your view model
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
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
}
