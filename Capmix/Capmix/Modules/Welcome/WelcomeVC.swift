
//
//  
//  WelcomeVC.swift
//  AudioRecord
//
//  Created by haiphan on 03/12/2021.
//
//
import UIKit
import RxCocoa
import RxSwift

class WelcomeVC: UIViewController {
    
    // Add here outlets
    @IBOutlet weak var btWelcome: UIButton!
    
    // Add here your view model
    private var viewModel: WelcomeVM = WelcomeVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
}
extension WelcomeVC {
    
    private func setupUI() {
        // Add here the setup for the UI
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.btWelcome.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            let vc = GrantSystemVC.createVC()
            wSelf.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
}
