
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
import AVFoundation

class NewProjectVC: BaseVC {
    
    struct Constant {
        static let withTimeLine: CGFloat = 60
        static let heightAudio: CGFloat = 80
        static let tagAddView: Int = 9999
        static let adjustAudio: CGFloat = 5
        static let increaseAudio: CGFloat = adjustAudio * 60
        static let space: Int = 16
        static let spaceMoveScroll: CGFloat = 6
    }
    
    enum Action: Int, CaseIterable {
        case volume, delete, split
    }
    
    enum ActionAudio: Int, CaseIterable {
        case play, previous, next
    }
    
    // Add here outlets
    @IBOutlet weak var timeLineStackView: UIStackView!
    @IBOutlet weak var vContentView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var btAddSound: UIButton!
    @IBOutlet weak var processView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var audioStackView: UIStackView!
    @IBOutlet weak var widthContentView: NSLayoutConstraint!
    @IBOutlet var bts: [UIButton]!
    @IBOutlet var btsAudio: [UIButton]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lbTime: UILabel!
    private var audioWidthConstraint: Constraint!
    private var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    // Add here your view model
    private var viewModel: NewProjectVM = NewProjectVM()
    @VariableReplay private var sourcesURL: [MutePoint] = []
    @VariableReplay private var audios: [SplitAudioModel] = []
    private let addAudioEvent: PublishSubject<Void> = PublishSubject.init()
    private var startPosition: CGFloat = 0
    private var listRange: [ABVideoRangeSlider] = []
    private var selectAudio: URL?
    private var selectRange: ABVideoRangeSlider?
    private var selectView: UIView?
    private var detectTime: Disposable?
    
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
    }
    
}
extension NewProjectVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        title = "New Projfect"
        self.scrollView.delegate = self
        
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
        self.startPosition = self.positionCenter()
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        Action.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let bt = wSelf.bts[type.rawValue]
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self, let url = wSelf.selectAudio, let selectView = wSelf.selectView else { return }
                switch type {
                case .delete:
                    if let index = wSelf.sourcesURL.firstIndex(where: { $0.url == url }) {
                        wSelf.sourcesURL.remove(at: index)
                    }
                    if let index = wSelf.audios.firstIndex(where: { $0.url == url }) {
                        wSelf.audios.remove(at: index)
                    }
                    if let range = wSelf.selectRange, let index = wSelf.listRange.firstIndex(where: { $0 == range }) {
                        wSelf.listRange[index].waveForm.removePath()
                        wSelf.listRange.remove(at: index)
                    }
                    let list = wSelf.audioStackView.subviews
                    if let index = list.firstIndex(where: { $0 == selectView }) {
                        wSelf.audioStackView.subviews[index].removeFromSuperview()
                    }
                case .volume:
                    wSelf.changeVolume(url: url, valueVolume: 10) { [weak self] outputURL in
                        guard let wSelf = self else { return }
                        if let index = wSelf.sourcesURL.firstIndex(where: { $0.url == url }) {
                            wSelf.sourcesURL[index].url = outputURL
                            
                        }
                        if let index = wSelf.audios.firstIndex(where: { $0.url == url }) {
                            wSelf.audios[index].url = outputURL
                        }
                    }
                case .split:
                    if let range = wSelf.selectRange?.waveForm {
                        print("==== detectPositionView \(wSelf.detectPositionView(view: range))")
                        let asset: AVAsset = AVAsset(url: url)
                        AudioManage.shared.trimmSound(inUrl: url, index: 1, start: 0, end: 5, folderSplit: ConstantApp.shared.folderConvert) { outputURL in
                            print(outputURL)
                        } failure: { _ in
                            
                        }

//                        AudioManage.shared.splitAudio(asset: asset, segment: 2, folderSplit: ConstantApp.shared.folderConvert)
                    }
                }
            }.disposed(by: wSelf.disposeBag)
        }
        
        ActionAudio.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let bt = wSelf.btsAudio[type.rawValue]
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self, let url = wSelf.selectAudio else { return }
                switch type {
                case .play:
                    if wSelf.btsAudio[ActionAudio.play.rawValue].isSelected {
                        wSelf.pauseAudio()
                        wSelf.clearAction()
                        wSelf.btsAudio[ActionAudio.play.rawValue].isSelected = false
                        wSelf.btsAudio[ActionAudio.play.rawValue].setImage(Asset.icPlayProject.image, for: .normal)
                    } else {
                        if wSelf.audioPlayer.rate > 0 {
                            wSelf.playAudio()
                            wSelf.autoRunTime()
                            wSelf.btsAudio[ActionAudio.play.rawValue].isSelected = true
                            wSelf.btsAudio[ActionAudio.play.rawValue].setImage(Asset.icPauseProject.image, for: .normal)
                        } else {
                            wSelf.playAudio(url: url, rate: 1, currentTime: 0)
                            wSelf.autoRunTime()
                            wSelf.btsAudio[ActionAudio.play.rawValue].isSelected = true
                            wSelf.btsAudio[ActionAudio.play.rawValue].setImage(Asset.icPauseProject.image, for: .normal)
                        }
                    }
                    
                case .next, .previous:
                    var currentTime = wSelf.audioPlayer.currentTime
                    if type == .next {
                        currentTime += Constant.adjustAudio
                    } else {
                        currentTime -= Constant.adjustAudio
                    }
                    wSelf.continueAudio(currenTime: currentTime)
                }
            }.disposed(by: wSelf.disposeBag)
        }
        
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
        
        self.$audios.asObservable().bind { [weak self] list in
            guard let wSelf = self else { return }
            let l = list.sorted(by: { $0.endSecond > $1.endSecond })
            wSelf.exportURLAudio(list: l)
        }.disposed(by: self.disposeBag)
        
    }
    
    private func modifyAudioFrame(maxLenght: Int, count: Int) {
        var f = self.audioStackView.frame
        let height = count * Int(Constant.heightAudio) + ((count - 1) * Constant.space )
        f.size = CGSize(width: maxLenght * Int(Constant.withTimeLine), height: height)
        self.audioStackView.frame = f
        self.widthContentView.constant = CGFloat((maxLenght * Int(Constant.withTimeLine))) + self.startPosition + 100
        
        if self.audioStackView.subviews.firstIndex(where: { $0.tag == Constant.tagAddView }) == nil {
            self.setupAddView()
        }
    }
    
    private func autoScrollView() {
        UIView.animate(withDuration: 0.1) {
            self.scrollView.contentOffset.x += Constant.spaceMoveScroll
        } completion: { _ in
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupAudioView(url: URL, startTime: CGFloat) {
        
        self.listRange.forEach { v in
            v.hideViews(hide: true)
            v.waveForm.changeColor(isSelect: false)
        }
        
        let v: UIView = UIView(frame: .zero)
        v.backgroundColor = .clear
        let contentView1: UIView = UIView(frame: CGRect(x: Int(startTime) * Int(Constant.withTimeLine) , y: 0, width: Int(url.getDuration()) * Int(Constant.withTimeLine), height: 80))
        contentView1.backgroundColor = .clear
        let rangeSliderView: ABVideoRangeSlider = ABVideoRangeSlider(frame: CGRect(x: 8,
                                                                                   y: 5,
                                                                                   width: contentView1.frame.size.width - 30,
                                                                                   height: 80))
        rangeSliderView.setVideoURL(videoURL: url, colorShow: Asset.pink.color, colorDisappear: Asset.charcoalGrey60.color)
        rangeSliderView.updateBgColor(colorBg: Asset.pink.color)
        rangeSliderView.hideTimeLine(hide: true)
        
//        contentView1.addSubview(waveForm)
        contentView1.addSubview(rangeSliderView)
        v.addSubview(contentView1)
        let count = self.audioStackView.subviews.count
        if count <= 0 {
            self.audioStackView.insertArrangedSubview(v, at: 0)
        } else {
            self.audioStackView.insertArrangedSubview(v, at: count - 1)
        }
        
        let btSelect: UIButton = UIButton(type: .custom)
        btSelect.setTitle(nil, for: .normal)
        contentView1.addSubview(btSelect)
        btSelect.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        btSelect.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.listRange.forEach { v in
                v.hideViews(hide: true)
                v.waveForm.changeColor(isSelect: false)
            }
            rangeSliderView.hideViews(hide: false)
            rangeSliderView.waveForm.changeColor(isSelect: true)
            wSelf.selectAudio = url
            wSelf.selectRange = rangeSliderView
            wSelf.selectView = v
        }.disposed(by: self.disposeBag)
        
        
        let s: SplitAudioModel = SplitAudioModel(view: contentView1,
                                                 startSecond: startTime,
                                                 endSecond: startTime + url.getDuration(),
                                                 url: url)
        self.selectAudio = url
        self.selectRange = rangeSliderView
        self.selectView = v
        self.audios.append(s)
        self.listRange.append(rangeSliderView)
    }
    
    private func exportURLAudio(list: [SplitAudioModel]) {
        guard let first = list.first, let url = first.url else { return }
        var l = list
        l.removeFirst()
        
        let audioEffect = AudioEffect()
        audioEffect.mergeAudiosSplits(musicUrl: url,
                                      timeStart: 0,
                                      timeEnd: first.endSecond,
                                      index: 1, listAudioProtocol: l,
                                      deplayTime: first.startAudio(), nameMusic: "self.nameMusic",
                                      folderName: ConstantApp.shared.folderConvert,
                                      nameId: "String") { [weak self] (outputURL, _) in
            guard let wSelf = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                AudioManage.shared.covertToAudio(url: outputURL, folder: ConstantApp.shared.folderConvert, type: .m4a) { [weak self] audioURL in
                    guard let wSelf = self else { return }
//                    wSelf.playAudio(url: audioURL, rate: 1, currentTime: 0)
                } failure: { _ in

                }
            }
//            wSelf.delegate?.mergeAudio(url: outputURL)
        } failure: { [weak self] (err, txt) in
            guard let wSelf = self else { return }
//            wSelf.delegate?.msgError(text: txt)
        }
    }
    
    private func changeVolume(url: URL, valueVolume: Float, complention: @escaping ((URL) -> Void)) {
        let audioEffect = AudioEffect()
        audioEffect.changeVolume(musicUrl: url,
                                 timeStart: 0,
                                 timeEnd: 0,
                                 valueVolume: valueVolume,
                                 folderName: ConstantApp.shared.folderConvert) { outputURL, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                complention(outputURL)
            }
        } failure: { error, _ in
            print(error.localizedDescription)
        }


    }
    
    private func playAudio() {
        self.audioPlayer.play()
    }
    
    private func stopAudio() {
        self.audioPlayer.stop()
    }
    
    private func pauseAudio() {
        self.audioPlayer.pause()
    }
    
    private func continueAudio(currenTime: CGFloat) {
        if currenTime >= self.audioPlayer.duration {
            self.audioPlayer.stop()
            self.finishAudio()
        } else if currenTime <= 0 {
            self.audioPlayer.currentTime = TimeInterval(0)
            self.audioPlayer.play()
            self.scrollView.setContentOffset(.zero, animated: true)
        } else {
            if currenTime >= self.audioPlayer.currentTime {
                UIView.animate(withDuration: 0.1) {
                    self.scrollView.contentOffset.x += Constant.increaseAudio
                } completion: { _ in
                    self.view.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.1) {
                    self.scrollView.contentOffset.x -= Constant.increaseAudio
                } completion: { _ in
                    self.view.layoutIfNeeded()
                }
            }
            self.audioPlayer.currentTime = TimeInterval(currenTime)
            self.audioPlayer.play()
        }
    }
    
    private func playAudio(url: URL, rate: Float, currentTime: CGFloat) {
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer.delegate = self
            self.audioPlayer.enableRate = true
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.volume = rate
            self.audioPlayer.play()
            self.audioPlayer.currentTime = TimeInterval(currentTime)
            self.autoRunTime()
        } catch {
        }
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
    
    private func finishAudio() {
        scrollView.setContentOffset(.zero, animated: true)
        self.clearAction()
        self.stopAudio()
        self.btsAudio[ActionAudio.play.rawValue].isSelected = false
        self.btsAudio[ActionAudio.play.rawValue].setImage(Asset.icPlayProject.image, for: .normal)
        self.lbTime.text = "00:00"
    }
    
    private func detectPositionView(view: UIView) -> CGFloat {
        return view.convert(self.centerView.frame, from: nil).origin.x
    }
    
    private func positionCenter() -> CGFloat {
        return self.scrollView.convert(self.centerView.frame, to: nil).origin.x
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
    
    private func addURL(detectTimeStart: CGFloat, url: URL) {
        let mutePoint: MutePoint = MutePoint(start: Float(detectTimeStart), end: Float(url.getDuration()), url: url)
        self.sourcesURL.append(mutePoint)
        self.setupAudioView(url: url, startTime: detectTimeStart)
    }
    
    private func clearAction() {
        detectTime?.dispose()
    }
    private func autoRunTime() {
        detectTime?.dispose()
        
        detectTime = Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] (time) in
                guard let wSelf = self else { return }
                wSelf.autoScrollView()
                wSelf.lbTime.text = "\(Int(wSelf.audioPlayer.currentTime).getTextFromSecond())"
            })
    }
    
}
extension NewProjectVC: ProjectListDelegate {
    func addMusic(url: URL) {
        let position = self.startPosition - self.positionCenter()
        let detectTimeStart = position / Constant.withTimeLine
        self.addURL(detectTimeStart: detectTimeStart, url: url)
    }
}
extension NewProjectVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}
extension NewProjectVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.finishAudio()
    }
}
