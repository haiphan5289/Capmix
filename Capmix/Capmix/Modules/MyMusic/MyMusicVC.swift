
//
//  
//  MyMusicVC.swift
//  Capmix
//
//  Created by haiphan on 27/04/2022.
//
//
import UIKit
import RxCocoa
import RxSwift
import EasyBaseAudio
import MobileCoreServices
import MediaPlayer
import StoreKit

protocol MyMusicDelegate {
    func addUrl(url: URL)
}

class MyMusicVC: BaseVC {
    
    enum openfrom {
        case home, importsProjects
    }
    
    var openfrom: openfrom = .home
    var delegate: MyMusicDelegate?
    
    // Add here outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Add here your view model
    private var viewModel: MyMusicVM = MyMusicVM()
    private var mediaItems = [MPMediaItem]()
    private var urlsEvent: BehaviorRelay<[URL]> = BehaviorRelay.init(value: [])
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupBackButtonSingle()
        self.navigationController?.isNavigationBarHidden = false
    }
    
}
extension MyMusicVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        self.checkAppleMusicPermission()
        title = "My Music"
        self.tableView.register(MyMusicCell.nib, forCellReuseIdentifier: MyMusicCell.identifier)
        self.tableView.delegate = self
        self.urlsEvent.accept(AudioManage.shared.getItemsFolder(folder: ConstantApp.shared.folderProject))
    }
    
    private func setupRX() {
//        Observable.just(AudioManage.shared.getItemsFolder(folder: ConstantApp.shared.folderApple))
        self.urlsEvent.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: MyMusicCell.identifier, cellType: MyMusicCell.self)) {(row, element, cell) in
                cell.loadValue(url: element)
            }.disposed(by: disposeBag)
        
        self.tableView.rx.itemSelected.bind { [weak self] idx in
            guard let wSelf = self else { return }
            let item = wSelf.urlsEvent.value[idx.row]
            switch wSelf.openfrom {
            case .home:
                var documentInteractionController: UIDocumentInteractionController!
                documentInteractionController = UIDocumentInteractionController.init(url: item)
                documentInteractionController?.delegate = self
                documentInteractionController?.presentPreview(animated: true)
            case .importsProjects:
                wSelf.navigationController?.popViewController(animated: true, {
                    wSelf.delegate?.addUrl(url: item)
                })
                
            }
        }.disposed(by: disposeBag)
    }
    
    func fetchApple() {
        mediaItems = MPMediaQuery.songs().items ?? []
        mediaItems.enumerated().forEach { (item) in
            AudioManage.shared.saveAppleMusic(folder: ConstantApp.shared.folderApple, mediaItem: item.element) { [weak self] outputURL in
                guard let wSelf = self else { return }
                wSelf.urlsEvent.accept(AudioManage.shared.getItemsFolder(folder: ConstantApp.shared.folderApple))
            } failure: { _ in
                
            }

        }
    }
    
    func checkAppleMusicPermission() {
        guard SKCloudServiceController.authorizationStatus() == .notDetermined else { return }
        SKCloudServiceController.requestAuthorization {(status: SKCloudServiceAuthorizationStatus) in
            switch status {
            case .denied, .restricted: break
            case .authorized:
                self.fetchApple()
            default: break
            }
        }
    }
    
}
extension MyMusicVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension MyMusicVC: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
