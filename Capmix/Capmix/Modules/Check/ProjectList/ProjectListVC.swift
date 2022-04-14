
//
//  
//  ProjectListVC.swift
//  Capmix
//
//  Created by haiphan on 14/04/2022.
//
//
import UIKit
import RxCocoa
import RxSwift

class ProjectListVC: BaseVC {
    
    enum TabAction: Int, CaseIterable {
        case projects, myMusic, recordings, importFiles
    }
    
    // Add here outlets
    @IBOutlet var ims: [UIImageView]!
    @IBOutlet var lbs: [UILabel]!
    @IBOutlet var bts: [UIButton]!
    
    // Add here your view model
    private var viewModel: ProjectListVM = ProjectListVM()
    @VariableReplay private var statusTap: TabAction = .projects
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.removeBorder()
        self.navigationController?.isNavigationBarHidden = false
        self.setupBtSearch()
    }
    
}
extension ProjectListVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        title = "Library"
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        TabAction.allCases.forEach { [weak self] action in
            guard let wSelf = self else { return }
            let bt = wSelf.bts[action.rawValue]
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                wSelf.statusTap = action
            }.disposed(by: wSelf.disposeBag)
        }
        
        self.$statusTap.asObservable().bind { [weak self] action in
            guard let wSelf = self else { return }
            switch action {
            case .projects:
                wSelf.ims[TabAction.projects.rawValue].image = Asset.icProjects.image
                wSelf.lbs[TabAction.projects.rawValue].textColor = Asset.pink.color
                
                wSelf.ims[TabAction.myMusic.rawValue].image = Asset.icMymusicInactive.image
                wSelf.lbs[TabAction.myMusic.rawValue].textColor = Asset.charcoalGrey60.color
                wSelf.ims[TabAction.recordings.rawValue].image = Asset.icRecordingInactive.image
                wSelf.lbs[TabAction.recordings.rawValue].textColor = Asset.charcoalGrey60.color
                wSelf.ims[TabAction.importFiles.rawValue].image = Asset.icImportInactive.image
                wSelf.lbs[TabAction.importFiles.rawValue].textColor = Asset.charcoalGrey60.color
            case .myMusic:
                wSelf.ims[TabAction.myMusic.rawValue].image = Asset.icMymusic.image
                wSelf.lbs[TabAction.myMusic.rawValue].textColor = Asset.pink.color
                
                wSelf.ims[TabAction.projects.rawValue].image = Asset.icProjectInactive.image
                wSelf.lbs[TabAction.projects.rawValue].textColor = Asset.charcoalGrey60.color
                wSelf.ims[TabAction.recordings.rawValue].image = Asset.icRecordingInactive.image
                wSelf.lbs[TabAction.recordings.rawValue].textColor = Asset.charcoalGrey60.color
                wSelf.ims[TabAction.importFiles.rawValue].image = Asset.icImportInactive.image
                wSelf.lbs[TabAction.importFiles.rawValue].textColor = Asset.charcoalGrey60.color
            case .recordings:
                wSelf.ims[TabAction.recordings.rawValue].image = Asset.icRecording.image
                wSelf.lbs[TabAction.recordings.rawValue].textColor = Asset.pink.color
                
                wSelf.ims[TabAction.projects.rawValue].image = Asset.icProjectInactive.image
                wSelf.lbs[TabAction.projects.rawValue].textColor = Asset.charcoalGrey60.color
                wSelf.ims[TabAction.myMusic.rawValue].image = Asset.icMymusicInactive.image
                wSelf.lbs[TabAction.myMusic.rawValue].textColor = Asset.charcoalGrey60.color
                wSelf.ims[TabAction.importFiles.rawValue].image = Asset.icImportInactive.image
                wSelf.lbs[TabAction.importFiles.rawValue].textColor = Asset.charcoalGrey60.color
            case .importFiles:
                wSelf.ims[TabAction.importFiles.rawValue].image = Asset.icImport.image
                wSelf.lbs[TabAction.importFiles.rawValue].textColor = Asset.pink.color
                
                wSelf.ims[TabAction.projects.rawValue].image = Asset.icProjectInactive.image
                wSelf.lbs[TabAction.projects.rawValue].textColor = Asset.charcoalGrey60.color
                wSelf.ims[TabAction.myMusic.rawValue].image = Asset.icMymusicInactive.image
                wSelf.lbs[TabAction.myMusic.rawValue].textColor = Asset.charcoalGrey60.color
                wSelf.ims[TabAction.recordings.rawValue].image = Asset.icRecordingInactive.image
                wSelf.lbs[TabAction.recordings.rawValue].textColor = Asset.charcoalGrey60.color
            }
        }.disposed(by: self.disposeBag)
    }
}
