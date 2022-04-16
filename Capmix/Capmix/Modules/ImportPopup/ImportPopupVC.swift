
//
//  
//  ImportPopupVC.swift
//  Capmix
//
//  Created by haiphan on 15/04/2022.
//
//
import UIKit
import RxCocoa
import RxSwift

protocol ImportPopupDelegate {
    func action(action: ImportPopupVC.Action)
}

class ImportPopupVC: UIViewController {
    
    enum Action: Int, CaseIterable {
        case close, photoLibrary, files
    }
    
    var delegate: ImportPopupDelegate?
    
    // Add here outlets
    @IBOutlet var bts: [UIButton]!
    
    // Add here your view model
    private var viewModel: ImportPopupVM = ImportPopupVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension ImportPopupVC {
    
    private func setupUI() {
        // Add here the setup for the UI
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        Action.allCases.forEach { [weak self] action in
            guard let wSelf = self else { return }
            let bt = wSelf.bts[action.rawValue]
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                switch action {
                case .close:
                    wSelf.dismiss(animated: true, completion: nil)
                case .files, .photoLibrary:
                    wSelf.dismiss(animated: true) {
                        wSelf.delegate?.action(action: action)
                    }
                }
            }.disposed(by: wSelf.disposeBag)
        }
    }
}
