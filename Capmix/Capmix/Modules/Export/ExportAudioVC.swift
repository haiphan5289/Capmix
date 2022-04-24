
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

class ExportAudioVC: BaseVC {
    
    // Add here outlets
    var audioURL: URL?
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var btNext: UIButton!
    // Add here your view model
    private var viewModel: ExportAudioVM = ExportAudioVM()
    
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
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.btNext.rx.tap.bind { [weak self] _ in
            guard let wSelf = self, let url = wSelf.audioURL, let nameAudio = wSelf.tfName.text, nameAudio.count > 0 else { return }
            AudioManage.shared.changeNameFile(folderName: ConstantApp.shared.folderProject, oldURL: url, newName: nameAudio) { [weak self] outputURL in
                guard let wSelf = self else { return }
                print("====== \(outputURL)")
            } failure: { text in
                print(text)
            }

        }.disposed(by: self.disposeBag)
    }
}
