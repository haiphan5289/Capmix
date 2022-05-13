
//
//  
//  LoadFirebaseVC.swift
//  AudioRecord
//
//  Created by haiphan on 06/12/2021.
//
//
import UIKit
import RxCocoa
import RxSwift

class LoadFirebaseVC: UIViewController {
    
    // Add here outlets
    
    // Add here your view model
    private var viewModel: LoadFirebaseVM = LoadFirebaseVM()
    
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
extension LoadFirebaseVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        FirebaseManage.share.fetchCloudValues { [weak self] isPrenium in
            guard let wSelf = self else { return }
            DispatchQueue.main.async {
                if isPrenium {
                    let vc = WelcomeVC.createVC()
                    wSelf.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = HomeVC.createVC()
                    wSelf.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    private func setupRX() {
        // Add here the setup for the RX
    }
}
