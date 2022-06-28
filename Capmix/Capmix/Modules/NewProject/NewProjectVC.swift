
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
import SVProgressHUD

class NewProjectVC: BaseVC {
    
    struct ABRangerModel {
        let abVideoRange: ABVideoRangeSlider
        let startTime: Float64
        let endTime: Float64
        init(abVideoRange: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
            self.abVideoRange = abVideoRange
            self.startTime = startTime
            self.endTime = endTime
        }
    }
    
    struct SplitAudio {
        let abVideoRange: ABVideoRangeSlider
        let startTime: Float64
        let detectTimeStart: CGFloat
        init(abVideoRange: ABVideoRangeSlider, startTime: Float64, detectTimeStart: CGFloat) {
            self.abVideoRange = abVideoRange
            self.startTime = startTime
            self.detectTimeStart = detectTimeStart
        }
    }
    
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
    @IBOutlet weak var viewVolume: UIView!
    @IBOutlet weak var btClose: UIButton!
    @IBOutlet weak var btDoneVolume: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var lbNameAudio: UILabel!
    @IBOutlet weak var leadingSV: NSLayoutConstraint!
    @IBOutlet weak var widthSV: NSLayoutConstraint!
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
    private var exportAudio: URL?
    private var scaleRange: PublishSubject<ABRangerModel> = PublishSubject.init()
    private var splitAudio: SplitAudio?
    private var isSplitAudio: Bool = false
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
        self.setupBtSearch(imageBack: Asset.icCloseProject.image, imgRight: Asset.icExport.image)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
        self.audioPlayer.pause()
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
            self.leadingSV.constant = self.positionCenter()
            
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
                    wSelf.deleteAudio(url: url, selectView: selectView)
                case .volume:
                    wSelf.viewVolume.isHidden = false
                    wSelf.lbNameAudio.text = url.getName()
                case .split:
                    if let video = wSelf.selectRange, let range = wSelf.selectRange?.waveForm {
                        print("==== detectPositionView \(wSelf.detectPositionView(view: range))")
                        let endTime = wSelf.detectPositionView(view: range) / Constant.withTimeLine
                        if endTime >= 2 {
                            wSelf.isSplitAudio = true
                            let position = wSelf.startPosition - wSelf.positionCenter()
                            let detectTimeStart = position / Constant.withTimeLine
                            if detectTimeStart >= 2 {
                                wSelf.splitAudio = SplitAudio(abVideoRange: video, startTime: endTime, detectTimeStart: detectTimeStart)
                                wSelf.scaleRange.onNext(ABRangerModel(abVideoRange: video, startTime: 0, endTime: endTime))
                            } else {
                                wSelf.isSplitAudio = false
                            }
                        }
                    }
                }
            }.disposed(by: wSelf.disposeBag)
        }
        
        ActionAudio.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let bt = wSelf.btsAudio[type.rawValue]
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self, let url = wSelf.exportAudio else { return }
                switch type {
                case .play:
                    if wSelf.btsAudio[ActionAudio.play.rawValue].isSelected {
                        wSelf.pauseAudio()
                        wSelf.clearAction()
                        wSelf.btsAudio[ActionAudio.play.rawValue].isSelected = false
                        wSelf.btsAudio[ActionAudio.play.rawValue].setImage(Asset.icPlayProject.image, for: .normal)
                    } else {
                        let position = wSelf.startPosition - wSelf.positionCenter()
                        let detectTimeStart = position / Constant.withTimeLine
                        wSelf.playAudio(url: url, rate: 1, currentTime: detectTimeStart)
                        wSelf.autoRunTime()
                        wSelf.btsAudio[ActionAudio.play.rawValue].isSelected = true
                        wSelf.btsAudio[ActionAudio.play.rawValue].setImage(Asset.icPauseProject.image, for: .normal)
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
        
        self.btClose.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.viewVolume.isHidden = true
        }.disposed(by: self.disposeBag)
        
        self.btDoneVolume.rx.tap.bind { [weak self] _ in
            guard let wSelf = self, let url = wSelf.selectAudio else { return }
            let value = wSelf.volumeSlider.value
            wSelf.viewVolume.isHidden = true
            wSelf.changeVolume(url: url, valueVolume: value) { [weak self] outputURL in
                guard let wSelf = self else { return }
                if let index = wSelf.sourcesURL.firstIndex(where: { $0.url == url }) {
                    wSelf.sourcesURL[index].url = outputURL
                    wSelf.selectAudio = outputURL
                    
                }
                if let index = wSelf.audios.firstIndex(where: { $0.url == url }) {
                    wSelf.audios[index].url = outputURL
                }
            }
        }.disposed(by: self.disposeBag)
        
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
            wSelf.modifyAudioFrame(maxLenght: Double(max ?? 0), count: Double(list.count + 1))
        }.disposed(by: self.disposeBag)
        
        self.$sourcesURL.asObservable().bind { [weak self] list in
            guard let wSelf = self else { return }
            let max = list.map { $0.getEndTime() }.max()
            if let max = max {
                wSelf.timeLineStackView.subviews.forEach { v in
                    v.removeFromSuperview()
                }
                wSelf.numberOfRecording(addSecond: Int(max))
            }
        }.disposed(by: self.disposeBag)
        
        self.scaleRange.debounce(.milliseconds(200), scheduler: MainScheduler.asyncInstance).bind { [weak self] abRange in
            guard let wSelf = self else { return }
            wSelf.scaleRangeVideo(abRange: abRange)
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
        
        self.btSearch.rx.tap.bind { [weak self] _ in
            guard let wSelf = self, let url = wSelf.exportAudio  else { return }
            let vc = ExportAudioVC.createVC()
            vc.audioURL = url
            vc.count = wSelf.sourcesURL.count
            wSelf.navigationController?.pushViewController(vc, completion: nil)
        }.disposed(by: self.disposeBag)
        
    }
    
    private func modifyAudioFrame(maxLenght: Double, count: Double) {
        var f = self.audioStackView.frame
        let height: Double = count * Double(Constant.heightAudio) + ((count - 1) * Double(Constant.space) )
        f.size = CGSize(width: maxLenght * Double(Constant.withTimeLine), height: height)
        self.audioStackView.frame = f
        self.widthContentView.constant = CGFloat((maxLenght * Double(Constant.withTimeLine))) + self.startPosition + 100
        
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
    
    private func setupAudioView(url: URL, startTime: CGFloat, index: Int? = nil) {
        
        self.listRange.forEach { v in
            v.hideViews(hide: true)
            v.waveForm.changeColor(isSelect: false)
        }
        
        let v: UIView = UIView(frame: .zero)
        v.backgroundColor = .clear
        let contentView1: UIView = UIView(frame: CGRect(x: Int(startTime) * Int(Constant.withTimeLine) ,
                                                        y: 0,
                                                        width: Int(url.getDuration()) * Int(Constant.withTimeLine),
                                                        height: 80))
        contentView1.backgroundColor = .clear
        let rangeSliderView: ABVideoRangeSlider = ABVideoRangeSlider(frame: CGRect(x: 8,
                                                                                   y: 5,
                                                                                   width: contentView1.frame.size.width - 30,
                                                                                   height: 80))
        rangeSliderView.setVideoURL(videoURL: url, colorShow: Asset.pink.color, colorDisappear: Asset.charcoalGrey60.color)
        rangeSliderView.updateBgColor(colorBg: Asset.pink.color)
        rangeSliderView.hideTimeLine(hide: true)
        rangeSliderView.delegate = self
        
//        contentView1.addSubview(waveForm)
        contentView1.addSubview(rangeSliderView)
        v.addSubview(contentView1)
        let count = self.audioStackView.subviews.count
        if count <= 0 {
            self.audioStackView.insertArrangedSubview(v, at: 0)
        } else if let index = index {
            self.audioStackView.insertArrangedSubview(v, at: index - 1)
        } else  {
            self.audioStackView.insertArrangedSubview(v, at: count - 1)
        }
        
        let btSelect: UIButton = UIButton(type: .custom)
        btSelect.setTitle(nil, for: .normal)
        contentView1.addSubview(btSelect)
        btSelect.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
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
        let randomIndex = Int.random(in: 0...999999)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            audioEffect.mergeAudiosSplits(musicUrl: url,
                                          timeStart: 0,
                                          timeEnd: first.endSecond,
                                          index: 1, listAudioProtocol: l,
                                          deplayTime: first.startAudio(),
                                          nameMusic: "self.nameMusic\(randomIndex)",
                                          folderName: ConstantApp.shared.folderConvert,
                                          nameId: AudioManage.shared.parseDatetoString()) { (outputURL, _) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    AudioManage.shared.covertToAudio(url: outputURL, folder: ConstantApp.shared.folderConvert, type: .m4a) { [weak self] audioURL in
                        guard let wSelf = self else { return }
                        wSelf.exportAudio = audioURL
                    } failure: { _ in
                    }
                }
            } failure: { (err, txt) in
            }
        }
    }
    
    private func addURLAfterSplit(url: URL, startTime: CGFloat, detectTimeStart: CGFloat) {
        AudioManage.shared.trimmSound(inUrl: url,
                                      index: 1, start: startTime,
                                      end: url.getDuration(),
                                      folderSplit: ConstantApp.shared.folderConvert) { [weak self] outputURL in
            guard let wSelf = self else { return }
            DispatchQueue.main.async {
                if let selectView = wSelf.selectView, let index = wSelf.audioStackView.subviews.firstIndex(where: { $0 == selectView }) {
                    wSelf.addURL(detectTimeStart: detectTimeStart, url: outputURL, index: index + 1)
                }
            }
        } failure: { text in
            print(text)
        }

    }
    
    private func scaleRangeVideo(abRange: ABRangerModel) {
        AudioManage.shared.trimmSound(inUrl: abRange.abVideoRange.videoURL,
                                      index: 1,
                                      start: abRange.startTime,
                                      end: abRange.endTime,
                                      folderSplit: ConstantApp.shared.folderConvert) { [weak self] outputURL in
            guard let wSelf = self, let url = wSelf.selectAudio, let selectView = wSelf.selectView else { return }
            DispatchQueue.main.async {
                if let index = wSelf.sourcesURL.firstIndex(where: { $0.url == url }),
                   let indexView = wSelf.audioStackView.subviews.firstIndex(where: { $0 == selectView }) {
                    let mutePointIndex = wSelf.sourcesURL[index]
                    wSelf.deleteAudio(url: url, selectView: selectView)
                    wSelf.addURL(detectTimeStart: CGFloat(mutePointIndex.start), url: outputURL, index: indexView)
                }
                
                if let spliAudio = wSelf.splitAudio, wSelf.isSplitAudio {
                    wSelf.isSplitAudio = false
                    wSelf.addURLAfterSplit(url: spliAudio.abVideoRange.videoURL, startTime: spliAudio.startTime, detectTimeStart: spliAudio.detectTimeStart)
                }
                
            }
        } failure: { text in
            print(text)
        }
    }
    
    private func deleteAudio(url: URL, selectView: UIView) {
        if let index = self.sourcesURL.firstIndex(where: { $0.url == url }) {
            self.sourcesURL.remove(at: index)
        }
        if let index = self.audios.firstIndex(where: { $0.url == url }) {
            self.audios.remove(at: index)
        }
        if let range = self.selectRange, let index = self.listRange.firstIndex(where: { $0 == range }) {
            self.listRange[index].waveForm.removePath()
            self.listRange.remove(at: index)
        }
        let list = self.audioStackView.subviews
        if let index = list.firstIndex(where: { $0 == selectView }) {
            self.audioStackView.subviews[index].removeFromSuperview()
        }
        self.selectAudio = nil
        self.selectView = nil
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
    
    private func getWidthAudio(duration: Int) -> Int {
        return duration * Int(Constant.withTimeLine)
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
        self.widthSV.constant = CGFloat(count * Constant.withTimeLine)
    }
    
    private func addTimeLineView(index: Int) {
        let v: UIView = UIView()
        let vTime: TimeLineView = TimeLineView.loadXib()
        vTime.lbTime.text = index.getTextFromSecond()
        
        v.addSubview(vTime)
        vTime.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.timeLineStackView.addArrangedSubview(v)
    }
    
    private func addURL(detectTimeStart: CGFloat, url: URL, index: Int? = nil) {
        let mutePoint: MutePoint = MutePoint(start: Float(detectTimeStart), end: Float(url.getDuration()), url: url)
        self.sourcesURL.append(mutePoint)
        self.setupAudioView(url: url, startTime: detectTimeStart, index: index)
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
extension NewProjectVC: ABVideoRangeSliderDelegate {
    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        if endTime - startTime >= 2 {
            self.scaleRange.onNext(ABRangerModel(abVideoRange: videoRangeSlider, startTime: startTime, endTime: endTime))
        }
    }
    
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
        
    }
    
    func updateFrameSlide(videoRangeSlider: ABVideoRangeSlider, startIndicator: CGFloat, endIndicator: CGFloat) {
        
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
