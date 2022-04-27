
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
import MobileCoreServices
import MediaPlayer
import StoreKit
import EasyBaseAudio
import SVProgressHUD

protocol ProjectListDelegate {
    func addMusic(url: URL)
}

class ProjectListVC: BaseVC {
    
    enum TabAction: Int, CaseIterable {
        case projects, myMusic, recordings, importFiles
    }
    
    enum ActionImported {
        case imported, musicApp
    }
    
    enum openfrom {
        case newProject, other
    }
    var openfrom: openfrom = .other
    var delegate: ProjectListDelegate?
    
    // Add here outlets
    @IBOutlet var ims: [UIImageView]!
    @IBOutlet var lbs: [UILabel]!
    @IBOutlet var bts: [UIButton]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var importView: UIView!
    @IBOutlet weak var btImported: UIButton!
    @IBOutlet weak var btMusicApp: UIButton!
    @IBOutlet weak var projectView: UIView!
    
    // Add here your view model
    private var viewModel: ProjectListVM = ProjectListVM()
    @VariableReplay private var statusTap: TabAction = .projects
    private var recordings: [URL] = []
    private var myMusics: [URL] = []
    private var myProjects: [URL] = []
    private var imports: [URL] = []
    private var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
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
        self.setupBtSearch(imageBack: Asset.icCloseProject.image, imgRight: Asset.icSearchProject.image)
    }
    
}
extension ProjectListVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        title = "Library"
        self.tableView.register(ProjectListCell.nib, forCellReuseIdentifier: ProjectListCell.identifier)
        self.tableView.register(MyMusicCell.nib, forCellReuseIdentifier: MyMusicCell.identifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        if self.openfrom == .newProject {
            self.statusTap = .myMusic
            self.projectView.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        TabAction.allCases.forEach { [weak self] action in
            guard let wSelf = self else { return }
            let bt = wSelf.bts[action.rawValue]
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                wSelf.statusTap = action
                wSelf.importView.isHidden = (action != .importFiles) ? true : false
                wSelf.tableView.reloadData()
            }.disposed(by: wSelf.disposeBag)
        }
        
        self.viewModel.imports.asObservable().bind(onNext: { [weak self] list in
            guard let wSelf = self else { return }
            wSelf.imports = list
        }).disposed(by: self.disposeBag)
        
        self.viewModel.mymusic.asObservable().bind(onNext: { [weak self] list in
            guard let wSelf = self else { return }
            wSelf.myMusics = list
            wSelf.myProjects = list
        }).disposed(by: self.disposeBag)
        
        self.viewModel.recordings.asObservable().bind(onNext: { [weak self] list in
            guard let wSelf = self else { return }
            wSelf.recordings = list
        }).disposed(by: self.disposeBag)
        
        let imported = self.btImported.rx.tap.map { ActionImported.imported }
        let musicApp = self.btMusicApp.rx.tap.map { ActionImported.musicApp }
        Observable.merge(imported, musicApp).bind { [weak self] action in
            guard let wSelf = self else { return }
            switch action {
            case .imported:
                let vc = ImportPopupVC.createVC()
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                vc.delegate = self
                wSelf.present(vc, animated: true, completion: nil)
            case .musicApp:
                let vc = MyMusicVC.createVC()
                vc.delegate = self
                vc.openfrom = .importsProjects
                wSelf.navigationController?.pushViewController(vc, completion: nil)
            }
        }.disposed(by: self.disposeBag)
        
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
extension ProjectListVC: ImportPopupDelegate {
    func action(action: ImportPopupVC.Action) {
        switch action {
        case .close: break
        case .photoLibrary:
            let vc = UIImagePickerController()
            vc.sourceType = .photoLibrary
            vc.mediaTypes = [kUTTypeMovie as String]
            self.present(vc, animated: true, completion: nil)
        case .files:
            let types = [kUTTypeMovie, kUTTypeVideo, kUTTypeAudio, kUTTypeQuickTimeMovie, kUTTypeMPEG, kUTTypeMPEG2Video]
            let documentPicker = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            //                        documentPicker.shouldShowFileExtensions = true
            self.present(documentPicker, animated: true, completion: nil)
        }
    }
}
extension ProjectListVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let first = urls.first else {
            return
        }
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AudioManage.shared.covertToCAF(folderConvert: ConstantApp.shared.folderImport, url: first, type: .caf) { [weak self] outputURLBrowser in
                guard let wSelf = self else { return }
                DispatchQueue.main.async {
                    wSelf.imports.append(outputURLBrowser)
                    wSelf.tableView.reloadData()
                    SVProgressHUD.dismiss()
                }
                
            } failure: { [weak self] text in
                SVProgressHUD.dismiss()
                guard let wSelf = self else { return }
                wSelf.showAlert(title: nil, message: text)
            }
        }

    }
    
//    private func playAudio(url: URL, rate: Float, currentTime: CGFloat) {
//        do {
//            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
////            self.audioPlayer.delegate = self
//            self.audioPlayer.enableRate = true
//            self.audioPlayer.prepareToPlay()
//            self.audioPlayer.volume = rate
//            self.audioPlayer.play()
//            self.audioPlayer.currentTime = TimeInterval(currentTime)
//        } catch {
//        }
//    }
}
extension ProjectListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.statusTap {
        case .importFiles:
            return self.imports.count
        case .projects:
            return self.myProjects.count
        case .myMusic:
            return self.myMusics.count
        case .recordings:
            return self.recordings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.statusTap {
        case .recordings:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MyMusicCell.identifier) as? MyMusicCell else {
                fatalError()
            }
            let item = self.recordings[indexPath.row]
            cell.loadValue(url: item)
            return cell
        case .myMusic:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MyMusicCell.identifier) as? MyMusicCell else {
                fatalError()
            }
            let item = self.myMusics[indexPath.row]
            cell.loadValue(url: item)
            return cell
        case .importFiles:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MyMusicCell.identifier) as? MyMusicCell else {
                fatalError()
            }
            let item = self.imports[indexPath.row]
            cell.loadValue(url: item)
            return cell
        case .projects:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProjectListCell.identifier) as? ProjectListCell else {
                fatalError()
            }
            let item = self.myProjects[indexPath.row]
            cell.loadValue(url: item)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectURL: URL?
        switch self.statusTap {
        case .recordings:
            selectURL = self.recordings[indexPath.row]
        case .myMusic:
            selectURL = self.myMusics[indexPath.row]
        case .importFiles:
            selectURL = self.imports[indexPath.row]

        case .projects:
            selectURL = self.myProjects[indexPath.row]
        }
        
        switch self.openfrom {
        case .newProject:
            if let item = selectURL {
                self.navigationController?.popViewController(animated: true, {
                    self.delegate?.addMusic(url: item)
                })
            }
        case .other:
            if let item = selectURL {
                var documentInteractionController: UIDocumentInteractionController!
                documentInteractionController = UIDocumentInteractionController.init(url: item)
                documentInteractionController?.delegate = self
                documentInteractionController?.presentPreview(animated: true)
            }
        }
    }
    
}
extension ProjectListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v: UIView = UIView()
        v.backgroundColor = .clear
        
        let contentView: UIView = UIView()
        v.addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 4
        
        let btHeader: UIButton = UIButton(type: .custom)
        switch self.statusTap {
        case .projects:
            btHeader.setTitle("New Project", for: .normal)
        case .recordings:
            btHeader.setTitle("New Recording", for: .normal)
        case .importFiles:
            btHeader.setTitle("Import Audio or Convert Audio from Video", for: .normal)
            
        case .myMusic: break
        }
        
        btHeader.setTitleColor(Asset.pink.color, for: .normal)
        btHeader.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 15)
        contentView.addSubview(btHeader)
        btHeader.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        btHeader.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            switch wSelf.statusTap {
            case .recordings:
                let vc = RecordingVC.createVC()
                vc.delegate = wSelf
                wSelf.navigationController?.pushViewController(vc, completion: nil)
            case .projects:
                let vc = NewProjectVC.createVC()
                wSelf.navigationController?.pushViewController(vc, completion: nil)
            case .myMusic, .importFiles: break
            }
        }.disposed(by: self.disposeBag)
        
        
        return v
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.statusTap {
        case .myMusic:
            return 0.1
        case .projects, .recordings, .importFiles: return 56
            
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension ProjectListVC: RecordingDelegate {
    func updateRecordings() {
        self.viewModel.getItemRecords()
        self.tableView.reloadData()
    }
}
extension ProjectListVC: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
extension ProjectListVC: MyMusicDelegate {
    func addUrl(url: URL) {
        self.imports.append(url)
        self.tableView.reloadData()
    }
}
