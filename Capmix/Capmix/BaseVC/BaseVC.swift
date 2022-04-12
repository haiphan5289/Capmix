//
//  BaseVC.swift
//  Capmix
//
//  Created by haiphan on 10/04/2022.
//

import UIKit
import EasyBaseCodes
import EasyBaseAudio
import RxSwift
import RxCocoa

class BaseVC: UIViewController {

    let buttonLeft = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            if let navBar = self.navigationController {
                let bar = navBar.navigationBar
                bar.standardAppearance = appearance
                bar.scrollEdgeAppearance = appearance
            }

        }
    }
}
extension BaseVC {
    
    private func setupRX() {
        self.buttonLeft.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.navigationController?.popViewController(animated: true, nil)
        }.disposed(by: self.disposeBag)
    }
    
    func setupBackButtonSingle() {
//        self.buttonLeft.setImage(UIImage(named: "icArrowLeft"), for: .normal)
        self.buttonLeft.setTitle("Button", for: .normal)
        self.buttonLeft.setTitleColor(.red, for: .normal)
        self.buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
}
