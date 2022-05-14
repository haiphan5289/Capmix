
//
//  
//  SettingVC.swift
//  Capmix
//
//  Created by haiphan on 14/05/2022.
//
//
import UIKit
import RxCocoa
import RxSwift
import EasyBaseAudio

class SettingVC: BaseVC {
    
    enum Action: Int, CaseIterable {
        case help, privacy, term
    }
    
    // Add here outlets
    @IBOutlet var bts: [UIButton]!
    
    // Add here your view model
    private var viewModel: SettingVM = SettingVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.setupBackButtonSingle()
    }
    
}
extension SettingVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        title = "Setting"
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        Action.allCases.forEach { type in
            let bt = self.bts[type.rawValue]
            bt.rx.tap.bind { _ in
                switch type {
                case .privacy:
                    AudioManage.shared.openLink(link: ConstantApp.shared.linkPrivacy)
                case .term:
                    AudioManage.shared.openLink(link: ConstantApp.shared.linkTerm)
                case .help:
                    AudioManage.shared.openLink(link: ConstantApp.shared.linkSUpport)
                }
            }.disposed(by: self.disposeBag)
        }
    }
}
