
//
//  
//  GrantSystemVC.swift
//  AudioRecord
//
//  Created by haiphan on 03/12/2021.
//
//
import UIKit
import RxCocoa
import RxSwift
import AVFoundation

class GrantSystemVC: BaseVC {
    
    struct Constant {
        static let x: CGFloat = 0
        static let y: CGFloat = 10
        static let blur: CGFloat = 15
        static let Spread: CGFloat = 0
    }
    
    // Add here outlets
    @IBOutlet weak var voiceView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var icCheckVoice: UIImageView!
    @IBOutlet weak var icCheckLocation: UIImageView!
    @IBOutlet weak var btGrantNow: UIButton!
    
    // Add here your view model
    private var viewModel: GrantSystemVM = GrantSystemVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
}
extension GrantSystemVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        self.voiceView.layer.applySketchShadow(color: Asset.backOpacity04.color,
                                                                       alpha: 1,
                                                                       x: Constant.x,
                                                                       y: Constant.y,
                                                                       blur: Constant.blur,
                                                                       spread: Constant.Spread)
        self.locationView.layer.applySketchShadow(color: Asset.backOpacity04.color,
                                                                       alpha: 1,
                                                                       x: Constant.x,
                                                                       y: Constant.y,
                                                                       blur: Constant.blur,
                                                                       spread: Constant.Spread)
        self.requestVoice()
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.btGrantNow.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            switch AVAudioSession.sharedInstance().recordPermission {
            case AVAudioSession.RecordPermission.granted:
                let vc = INAPPVC.createVC()
                vc.delegate = self
                vc.openfrom = .welcome
                wSelf.present(vc, animated: true, completion: nil)
            case AVAudioSession.RecordPermission.denied, AVAudioSession.RecordPermission.undetermined: break
            @unknown default: break
            }
        }.disposed(by: disposeBag)
    }
    
    private func requestVoice() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            self.icCheckVoice.image = Asset.icAllowed.image
        case AVAudioSession.RecordPermission.denied:
            self.icCheckVoice.image = Asset.icUnAllow.image
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                DispatchQueue.main.async {
                    self.icCheckVoice.image = (granted) ? Asset.icAllowed.image : Asset.icUnAllow.image
                }
            })
        @unknown default: break
        }
    }
    
}

extension GrantSystemVC: INAPPDelegate {
    func dismiss() {
        let vc = HomeVC.createVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
