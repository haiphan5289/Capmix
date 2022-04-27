
//
//  
//  ExportAudioVC.swift
//  Capmix
//
//  Created by haiphan on 24/04/2022.
//
//
import UIKit
import RxCocoa
import RxSwift
import EasyBaseAudio
import EasyBaseCodes

class ExportAudioVC: BaseVC {
    
    enum ActionSuccess: Int, CaseIterable {
        case viewLibrary, share, continueMixing
    }
    
    // Add here outlets
    var audioURL: URL?
    var count: Int = 0
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var btNext: UIButton!
    @IBOutlet weak var bottomStackView: NSLayoutConstraint!
    @IBOutlet weak var exportView: UIView!
    @IBOutlet weak var successView: UIView!
    @IBOutlet var btsSuccess: [UIButton]!
    // Add here your view model
    private var viewModel: ExportAudioVM = ExportAudioVM()
    private var audioSuccess: URL?
    
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
extension ExportAudioVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        title = "Export Audio"
        self.tfName.becomeFirstResponder()
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.btNext.rx.tap.bind { [weak self] _ in
            guard let wSelf = self, let url = wSelf.audioURL, let nameAudio = wSelf.tfName.text, nameAudio.count > 0 else { return }
            AudioManage.shared.changeNameFile(folderName: ConstantApp.shared.folderProject, oldURL: url, newName: nameAudio) { [weak self] outputURL in
                guard let wSelf = self else { return }
                DispatchQueue.main.async {
                    wSelf.exportView.isHidden = true
                    wSelf.navigationController?.isNavigationBarHidden = true
                    wSelf.tfName.resignFirstResponder()
                    wSelf.audioSuccess = outputURL
                    wSelf.successView.isHidden = false
                    RealmManager.shared.updateOrInsertProject(model: ProjectModel(url: outputURL, count: Double(wSelf.count)))
                }
                
            } failure: { text in
                print(text)
            }

        }.disposed(by: self.disposeBag)
        
        ActionSuccess.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let bt = wSelf.btsSuccess[type.rawValue]
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                switch type {
                case .viewLibrary:
                    let vc = HomeVC.createVC()
                    wSelf.navigationController?.pushViewController(vc, completion: nil)
                case .continueMixing:
                    wSelf.navigationController?.popViewController(animated: true, nil)
                case .share:
                    if let url = wSelf.audioSuccess {
                        wSelf.presentActivty(url: url)
                    }
                   
                }
            }.disposed(by: wSelf.disposeBag)
        }
        
        
        let show = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map { KeyboardInfo($0) }
        let hide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map { KeyboardInfo($0) }
        
        Observable.merge(show, hide).bind { [weak self] keyboard in
            guard let wSelf = self else { return }
            wSelf.runAnimate(by: keyboard)
        }.disposed(by: disposeBag)
    }
    
    private func runAnimate(by keyboarInfor: KeyboardInfo?) {
        guard let i = keyboarInfor else {
            return
        }
        let h = i.height
        let d = i.duration
        
        UIView.animate(withDuration: d) {
            self.bottomStackView.constant = ( h > 0 ) ? h : 16
        }
    }
}
