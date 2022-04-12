
//
//  
//  RecordingVC.swift
//  Capmix
//
//  Created by haiphan on 12/04/2022.
//
//
import UIKit
import RxCocoa
import RxSwift
import SnapKit
import EasyBaseAudio

class RecordingVC: BaseVC {
    
    struct Constant {
        static let offSetShadow: CGSize = CGSize(width: 0, height: -17)
        static let opacityShadow: Float = 1
        static let radiusShadow: CGFloat = 54
        static let spaceMoveScroll: CGFloat = 4
        static let mimiumMeter: CGFloat = 41
        static let pixelWidth: CGFloat = 1
        static let pixelSpacing: CGFloat = 1
        static let maximumHeightSound: CGFloat = 500
        static let convertMilleToSecond: CGFloat = 10
    }
    
    enum Action {
        case prepare, play, stop
    }
    
    // Add here outlets
    @IBOutlet weak var btPlay: UIButton!
    @IBOutlet weak var btStop: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var vContentView: UIView!
    
    // Add here your view model
    private var viewModel: RecordingVM = RecordingVM()
    private var recording: Recording!
    @VariableReplay private var status: Action = .prepare
    private var currentPosition: CGFloat = 0
    private var startPosition: CGFloat = 0
    private var autoTime: Disposable?
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.currentPosition = self.positionXBetweenCenterAndScrollView()
        self.startPosition = self.positionXBetweenCenterAndScrollView()
    }
    
}
extension RecordingVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        title = "Recording"
        self.recording = Recording(folderName: "\(ConstantApp.shared.folderRecording)")
        do {
            try self.recording.prepare()
        } catch {

        }
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.btPlay.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.status = .play
        }.disposed(by: self.disposeBag)
        
        self.btStop.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.status = .stop
        }.disposed(by: self.disposeBag)
        
        self.$status.asObservable().bind { [weak self] type in
            guard let wSelf = self else { return }
            
            switch type {
            case .prepare:
                wSelf.btPlay.layer.borderWidth = 7
            case .play:
                wSelf.btPlay.layer.borderWidth = 17
                do {
                    try  wSelf.recording.record()
                    wSelf.autoRunTimeMilieReplace()
                } catch {
                    print(error.localizedDescription)
                }
            case .stop:
                wSelf.btPlay.layer.borderWidth = 17
                wSelf.recording.stop()
                wSelf.clearActionMilieReplace()
                wSelf.navigationController?.popViewController(animated: true, nil)
                print("======= \(wSelf.recording.url)")
            }
            
        }.disposed(by: self.disposeBag)
        
    }
    
    private func drawWaveView(_ rect: CGRect, positionX: CGFloat, height: CGFloat) {
        let position = self.startPosition - self.positionXBetweenCenterAndScrollView() + self.startPosition
        print("====== position \(position)")
        print("====== height \(height)")
        let v: UIView = UIView(frame: .zero)
        v.backgroundColor = .red
        self.vContentView.addSubview(v)
        v.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(positionX)
            make.height.equalTo(100)
            make.width.equalTo(Constant.pixelWidth)
        }
    }
    
    private func autoScrollView() {
        UIView.animate(withDuration: 0.1) {
            self.scrollView.contentOffset.x += Constant.spaceMoveScroll
        } completion: { _ in
            self.view.layoutIfNeeded()
        }
    }
    
    private func positionXBetweenCenterAndScrollView() -> CGFloat {
        return self.vContentView.convert(self.centerView.frame, to: nil).origin.x
    }
    
    private func clearActionMilieReplace() {
        autoTime?.dispose()
    }
    private func autoRunTimeMilieReplace() {
        autoTime?.dispose()

        autoTime = Observable<Int>.interval(.milliseconds(10), scheduler: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] (time) in
                guard let wSelf = self, let recording = wSelf.recording else { return }
                if time % 10 == 0 {
                    recording.recorder?.updateMeters()
                    let ave = recording.recorder?.averagePower(forChannel: 0) ?? 0
                    let peak = recording.recorder?.peakPower(forChannel: 0) ?? 0
                    let h = (((CGFloat(ave) + Constant.mimiumMeter + 5) * wSelf.scrollView.frame.height) / Constant.maximumHeightSound)
                    wSelf.autoScrollView()
                    wSelf.drawWaveView(wSelf.vContentView.frame, positionX: wSelf.currentPosition, height: h)
                }
            })
    }
    
}
