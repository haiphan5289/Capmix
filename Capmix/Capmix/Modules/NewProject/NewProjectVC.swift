
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

class NewProjectVC: BaseVC {
    
    struct Constant {
        static let withTimeLine: CGFloat = 60
    }
    
    // Add here outlets
    @IBOutlet weak var timeLineStackView: UIStackView!
    @IBOutlet weak var vContentView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var btAddSound: UIButton!
    @IBOutlet weak var processView: UIView!
    @IBOutlet weak var emptyView: UIView!
    private var audioStackView: UIStackView!
    private var audioWidthConstraint: Constraint!
    
    // Add here your view model
    private var viewModel: NewProjectVM = NewProjectVM()
    @VariableReplay private var sourcesURL: [URL] = []
    
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
        self.audioStackView = UIStackView(arrangedSubviews: [],
                                          axis: .vertical,
                                          spacing: 16,
                                          alignment: .fill, distribution: .fillEqually)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var f = self.timeLineStackView.frame
            f.origin.y = 0
            f.origin.x = self.positionCenter()
            self.timeLineStackView.frame = f
            
            self.vContentView.addSubview(self.audioStackView)
            self.audioStackView.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(self.positionCenter())
                make.top.equalToSuperview().inset(self.timeLineStackView.frame.height + 30)
                self.audioWidthConstraint = make.width.equalTo(50).constraint
            }
        }
        self.numberOfRecording(addSecond: 600)
        
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
        }.disposed(by: self.disposeBag)
        
        self.btAddSound.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            let vc = ProjectListVC.createVC()
            vc.openfrom = .newProject
            vc.delegate = self
            wSelf.navigationController?.pushViewController(vc, completion: nil)
        }.disposed(by: self.disposeBag)
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
        self.sourcesURL.append(url)
        
        let v: UIView = UIView(frame: .zero)
        v.backgroundColor = .red
        
        let v2: UIView = UIView(frame: .zero)
        v2.backgroundColor = .red
        
        self.audioStackView.addArrangedSubview(v)
        self.audioStackView.addArrangedSubview(v2)
        self.audioStackView.snp.makeConstraints { make in
            self.audioWidthConstraint = make.width.equalTo(200).constraint
            make.height.equalTo(200)
        }
        print("====== \(self.audioStackView.frame)")
    }
}
