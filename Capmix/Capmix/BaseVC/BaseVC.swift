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
    let btSearch = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupRX()
        AudioManage.shared.createFolder(path: "\(ConstantApp.shared.folderRecording)") { outputURL in
            print("==== \(outputURL)")
        } failure: { _ in
            
        }
        AudioManage.shared.createFolder(path:  "\(ConstantApp.shared.folderApple)", success: nil, failure: nil)
        AudioManage.shared.createFolder(path:  "\(ConstantApp.shared.folderConvert)", success: nil, failure: nil)
        AudioManage.shared.createFolder(path:  "\(ConstantApp.shared.folderProject)", success: nil, failure: nil)
        AudioManage.shared.createFolder(path:  "\(ConstantApp.shared.folderImport)", success: nil, failure: nil)
        
        AudioManage.shared.removeFilesFolder(name: ConstantApp.shared.folderConvert)
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
        self.buttonLeft.setImage(Asset.icCloseProject.image, for: .normal)
        self.buttonLeft.setTitleColor(.red, for: .normal)
        self.buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func setupBtSearch(imageBack: UIImage, imgRight: UIImage) {
        self.buttonLeft.setImage(imageBack, for: .normal)
        self.buttonLeft.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        let leftBarButton = UIBarButtonItem(customView: buttonLeft)
        navigationItem.leftBarButtonItem = leftBarButton
        
        self.btSearch.setImage(imgRight, for: .normal)
        self.btSearch.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -16)
        let searchBt = UIBarButtonItem(customView: btSearch)
        navigationItem.rightBarButtonItem = searchBt
    }
    
    func removeBorder() {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.configureWithTransparentBackground()
            if let navBar = self.navigationController {
                let bar = navBar.navigationBar
                bar.standardAppearance = appearance
                bar.scrollEdgeAppearance = appearance
            }
        } else {
            self.navigationController?.hideHairline()
        }
    }
    
}
extension UINavigationController {
    func hideHairline() {
        if let hairline = findHairlineImageViewUnder(navigationBar) {
            hairline.isHidden = true
        }
    }
    func restoreHairline() {
        if let hairline = findHairlineImageViewUnder(navigationBar) {
            hairline.isHidden = false
        }
    }
    func findHairlineImageViewUnder(_ view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }
        for subview in view.subviews {
            if let imageView = self.findHairlineImageViewUnder(subview) {
                return imageView
            }
        }
        return nil
    }
}
