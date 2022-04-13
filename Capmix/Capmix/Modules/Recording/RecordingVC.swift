
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
        static let spaceMoveScroll: CGFloat = 6
        static let pixelWidth: CGFloat = 1
        static let pixelSpacing: CGFloat = 1
        static let withTimeLine: CGFloat = 60
        static let miniMeter: CFloat = 50
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
    @IBOutlet weak var timeLineStackView: UIStackView!
    
    // Add here your view model
    private var viewModel: RecordingVM = RecordingVM()
    private var recording: Recording!
    @VariableReplay private var status: Action = .prepare
    private var currentPosition: CGFloat = 0
    private var startPosition: CGFloat = 0
    private let valueMeter: PublishSubject<CFloat> = PublishSubject.init()
    
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
        self.recording.delegate = self
        do {
            try self.recording.prepare()
        } catch {

        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var f = self.timeLineStackView.frame
            f.origin.y = 0
            f.origin.x = self.positionXBetweenCenterAndScrollView()
            self.timeLineStackView.frame = f
        }
        self.numberOfRecording(addSecond: 60)
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.btPlay.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            
            if wSelf.btPlay.isSelected {
                wSelf.status = .stop
            } else {
                wSelf.btPlay.isSelected = true
                wSelf.status = .play
            }
            
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
                } catch {
                    print(error.localizedDescription)
                }
            case .stop:
                wSelf.btPlay.layer.borderWidth = 17
                wSelf.recording.stop()
                wSelf.navigationController?.popViewController(animated: true, nil)
                print("====== Recording Finish =====")
                print(wSelf.recording.url)
                print("====== ******* =====")
            }
            
        }.disposed(by: self.disposeBag)
        
        self.valueMeter.throttle(.milliseconds(100), scheduler: MainScheduler.asyncInstance).bind { [weak self] value in
            guard let wSelf = self else { return }
            let valueMeter = value + Constant.miniMeter
            wSelf.autoScrollView()
            wSelf.drawWaveView(height: valueMeter)
        }.disposed(by: self.disposeBag)
        
    }
    
    private func drawWaveView(height: Float) {
        let position = self.startPosition - self.positionXBetweenCenterAndScrollView() + self.startPosition
        let v: UIView = UIView(frame: .zero)
        v.backgroundColor = .red
        self.vContentView.addSubview(v)
        v.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(position)
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
    
    private func numberOfRecording(addSecond: Int) {
        for i in 0...addSecond {
            self.addTimeLineView(index: i)
        }
        let count: CGFloat = CGFloat(self.timeLineStackView.subviews.count)
        var f = self.timeLineStackView.frame
        f.size.width = CGFloat(count * Constant.withTimeLine)
        self.timeLineStackView.frame = f
    }
    
    private func addTimeLineView(index: Int) {
        let v: TimeLineView = TimeLineView.loadXib()
        v.frame = CGRect(origin: .zero, size: CGSize(width: Constant.withTimeLine, height: 28))
        v.lbTime.text = index.getTextFromSecond()
        
        self.timeLineStackView.addArrangedSubview(v)
    }
    
}
extension RecordingVC: RecorderDelegate {
    func audioMeterDidUpdate(_ dB: Float) {
        self.valueMeter.onNext(dB)
    }
}
