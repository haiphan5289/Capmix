
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
import CoreLocation

class GrantSystemVC: BaseNavigationSimple {
    
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
    private var locationManager: CLLocationManager = CLLocationManager()
    
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
        self.setupLocation()
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.btGrantNow.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            switch AVAudioSession.sharedInstance().recordPermission {
            case AVAudioSession.RecordPermission.granted:
                let vc = BackUpWelcomeVC.createVC()
                wSelf.navigationController?.pushViewController(vc, animated: true)
            case AVAudioSession.RecordPermission.denied, AVAudioSession.RecordPermission.undetermined:
                let vc = PermissionRequiredVC.createVC()
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                vc.delegate = self
                wSelf.present(vc, animated: true, completion: nil)
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
    
    private func getAuthorizationStatus() -> CLAuthorizationStatus {
            if #available(iOS 14.0, *) {
                return locationManager.authorizationStatus
            } else {
                return CLLocationManager.authorizationStatus()
            }
    }
    
    func setupLocation() {
        let status = getAuthorizationStatus()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        if status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled() {
            return
        }

        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
    }
}
extension GrantSystemVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.icCheckLocation.image = Asset.icAllowed.image
        default:
            self.icCheckLocation.image = Asset.icUnAllow.image
        }
    }
}

extension GrantSystemVC: PermissionRequiredDelegate {
    func dismissPerrmision() {
        
    }
    
    func laterSetting() {
        let vc = BackUpWelcomeVC.createVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
