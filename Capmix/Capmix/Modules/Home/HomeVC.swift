
//
//  
//  HomeVC.swift
//  Capmix
//
//  Created by haiphan on 10/04/2022.
//
//
import UIKit
import RxCocoa
import RxSwift
import EasyBaseAudio

class HomeVC: BaseVC {
    
    enum ElementHomeCell: Int, CaseIterable {
        case newMix, myMusic, recording
        
        var title: String {
            switch self {
            case .newMix: return "Create New Mix"
            case .myMusic: return "My Music"
//            case .projects: return "Projects"
            case .recording: return "Recording"
            }
        }
        
        var subTitle: String {
            switch self {
            case .newMix: return "Make the music or podcast easy than you think"
            case .myMusic: return "Browe your music that you’ve mixed"
//            case .projects: return "Your nearly projects"
            case .recording: return "Record audio with high quality"
            }
        }
        
        var img: UIImage {
            switch self {
            case .newMix: return Asset.imgCreate.image
            case .myMusic: return Asset.imgMusic.image
//            case .projects: return Asset.imgCreate.image
            case .recording: return Asset.imgRecording.image
            }
        }
        
    }
    
    // Add here outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btPremium: UIButton!
    @IBOutlet weak var btSetting: UIButton!
    
    // Add here your view model
    private var viewModel: HomeVM = HomeVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
}
extension HomeVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        self.tableView.register(HomeCell.nib, forCellReuseIdentifier: HomeCell.identifier)
        self.tableView.register(ProjectsCell.nib, forCellReuseIdentifier: ProjectsCell.identifier)
        self.tableView.delegate = self
        AudioManage.shared.removeFilesFolder(name: ConstantApp.shared.folderConvert)
        self.createRecorder()
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        self.btPremium.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            let vc = INAPPVC.createVC()
            vc.modalPresentationStyle = .overFullScreen
            wSelf.present(vc, animated: true, completion: nil)
        }.disposed(by: self.disposeBag)
        
        Observable.just(ElementHomeCell.allCases).bind(to: tableView.rx.items){(tv, row, item) -> UITableViewCell in
            guard let type = ElementHomeCell(rawValue: row) else {
                fatalError()
            }
            switch type {
//            case .projects: break
//                guard let cell = tv.dequeueReusableCell(withIdentifier: ProjectsCell.identifier, for: IndexPath.init(row: row, section: 0)) as? ProjectsCell else {
//                    fatalError()
//                }
//                cell.dataProjects()
//                return cell
            default:
                guard let cell = tv.dequeueReusableCell(withIdentifier: HomeCell.identifier, for: IndexPath.init(row: row, section: 0)) as? HomeCell else {
                    fatalError()
                }
                cell.dataHomeCell(element: item)
                return cell
            }
            
        }.disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind { [weak self] idx in
            guard let wSelf = self, let type = ElementHomeCell(rawValue: idx.row) else { return }
            switch type {
            case .recording:
                let vc = RecordingVC.createVC()
                wSelf.navigationController?.pushViewController(vc, completion: nil)
//            case .projects:
//                let vc = ProjectListVC.createVC()
//                wSelf.navigationController?.pushViewController(vc, completion: nil)
            case .newMix:
                let vc = NewProjectVC.createVC()
                wSelf.navigationController?.pushViewController(vc, completion: nil)
            case .myMusic:
                let vc = ProjectListVC.createVC()
                wSelf.navigationController?.pushViewController(vc, completion: nil)
                
//                let vc = MyMusicVC.createVC()
//                wSelf.navigationController?.pushViewController(vc, completion: nil)
            }
        }.disposed(by: disposeBag)
        
        self.btSetting.rx.tap.bind { [weak self] _ in
            guard let wSelf = self else { return }
            let vc = SettingVC.createVC()
            wSelf.navigationController?.pushViewController(vc, completion: nil)
        }.disposed(by: self.disposeBag)
    }
    
    //create a record to be not error when start record
    func createRecorder() {
        let recording = Recording(folderName: "\(ConstantApp.shared.folderConvert)")
        // Optionally, you can prepare the recording in the background to
        // make it start recording faster when you hit `record()`.

        DispatchQueue.global().async {
            // Background thread
            do {
                try recording.prepare()
                try recording.record()
            } catch {
                print(error)
            }
        }
        recording.stop()
    }
    
}
extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
