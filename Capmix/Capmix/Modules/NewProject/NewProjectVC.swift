
//
//  
//  NewProjectVC.swift
//  Capmix
//
//  Created by haiphan on 18/04/2022.
//
//
import UIKit
import RxCocoa
import RxSwift
import SnapKit
import EasyBaseAudio

class NewProjectVC: BaseVC {
    
    struct Constant {
        static let withTimeLine: CGFloat = 60
        static let heightAudio: CGFloat = 80
        static let tagAddView: Int = 9999
    }
    
    // Add here outlets
    @IBOutlet weak var timeLineStackView: UIStackView!
    @IBOutlet weak var vContentView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var btAddSound: UIButton!
    @IBOutlet weak var processView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var audioStackView: UIStackView!
    private var audioWidthConstraint: Constraint!
    
    // Add here your view model
    private var viewModel: NewProjectVM = NewProjectVM()
    @VariableReplay private var sourcesURL: [MutePoint] = []
    private let addAudioEvent: PublishSubject<Void> = PublishSubject.init()
    
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
extension NewProjectVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        title = "New Projfect"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var f = self.timeLineStackView.frame
            f.origin.y = 0
            f.origin.x = self.positionCenter()
            self.timeLineStackView.frame = f
            
            var fAudio = self.audioStackView.frame
            fAudio.origin.x = self.positionCenter()
            fAudio.origin.y = self.timeLineStackView.frame.height + 30
            fAudio.size = CGSize(width: 50, height: 100)
            self.audioStackView.frame = fAudio
            
            self.numberOfRecording(addSecond: 600)
        }
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.$sourcesURL.asObservable().bind { [weak self] list in
            guard let wSelf = self else { return }
            if list.count > 0 {
                wSelf.processView.isHidden = false
                wSelf.emptyView.isHidden = true
            } else {
                wSelf.processView.isHidden = true
                wSelf.emptyView.isHidden = false
            }
            let max = list.map { $0.getEndTime() }.max()
            wSelf.modifyAudioFrame(maxLenght: Int(max ?? 0), count: list.count + 1)
        }.disposed(by: self.disposeBag)
        
        Observable.merge(self.btAddSound.rx.tap.mapToVoid(), self.addAudioEvent.asObservable().mapToVoid())
            .bind { [weak self] _ in
            guard let wSelf = self else { return }
            let vc = ProjectListVC.createVC()
            vc.openfrom = .newProject
            vc.delegate = self
            wSelf.navigationController?.pushViewController(vc, completion: nil)
        }.disposed(by: self.disposeBag)
    }
    
    private func modifyAudioFrame(maxLenght: Int, count: Int) {
        var f = self.audioStackView.frame
        f.size = CGSize(width: maxLenght, height: count * Int(Constant.heightAudio))
        self.audioStackView.frame = f
        print("======  audioStackView \(self.audioStackView.frame)")
        
        if self.audioStackView.subviews.firstIndex(where: { $0.tag == Constant.tagAddView }) == nil {
            self.setupAddView()
        }
    }
    
    private func setupAudioView(url: URL) {
        let v: UIView = UIView(frame: .zero)
        v.backgroundColor = .clear
        let contentView1: UIView = UIView(frame: CGRect(x: 0, y: 0, width: url.getDuration() * 60, height: 70))
        contentView1.backgroundColor = .clear
        let waveForm: WaveformZoomable = WaveformZoomable(frame: CGRect(x: 0,
                                                                        y: 5,
                                                                        width: url.getDuration() * 60,
                                                                        height: 70))
        waveForm.backgroundColor = .clear
        waveForm.listPointtoDraw(file: url, viewSoundWave: .audio) { [weak self] list in

        }
        contentView1.addSubview(waveForm)
        v.addSubview(contentView1)
        self.audioStackView.insertArrangedSubview(v, at: 0)
        
    }
    
    private func setupAddView() {
        let v: UIView = UIView(frame: .zero)
        v.tag = Constant.tagAddView
        let bodyView: UIView = UIView(frame: .zero)
        v.addSubview(bodyView)
        bodyView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        bodyView.backgroundColor = .white
        
        let stackView: UIStackView = UIStackView(arrangedSubviews: [],
                                                 axis: .horizontal,
                                                 spacing: 16,
                                                 alignment: .center,
                                                 distribution: .fill)
        bodyView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.left.right.equalToSuperview().inset(20)
        }
        
        let imgPlus: UIImageView = UIImageView(image: Asset.icPlusAudio.image)
        imgPlus.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
        stackView.addArrangedSubview(imgPlus)
        
        let lbAdd: UILabel = UILabel(text: "Add Sound Track")
        lbAdd.font = UIFont.systemFont(ofSize: 13)
        lbAdd.textColor = Asset.charcoalGrey60.color
        stackView.addArrangedSubview(lbAdd)
        
        let btAdd: UIButton = UIButton(type: .custom)
        btAdd.setTitle(nil, for: .normal)
        v.addSubview(btAdd)
        btAdd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        btAdd.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.addAudioEvent.onNext(())
        }.disposed(by: self.disposeBag)
        
        
        self.audioStackView.addArrangedSubview(v)
    }
    
    private func positionCenter() -> CGFloat {
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
extension NewProjectVC: ProjectListDelegate {
    func addMusic(url: URL) {
        let mutePoint: MutePoint = MutePoint(start: Float(self.positionCenter()), end: Float(url.getDuration()), url: url)
        self.sourcesURL.append(mutePoint)
        self.setupAudioView(url: url)
    }
}
