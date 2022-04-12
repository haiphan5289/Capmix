
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

class HomeVC: BaseVC {
    
    enum ElementHomeCell: Int, CaseIterable {
        case newMix, myMusic, projects, recording
        
        var title: String {
            switch self {
            case .newMix: return "Create New Mix"
            case .myMusic: return "My Music"
            case .projects: return "Projects"
            case .recording: return "Recording"
            }
        }
        
        var subTitle: String {
            switch self {
            case .newMix: return "Make the music or podcast easy than you think"
            case .myMusic: return "Browe your music that you’ve mixed"
            case .projects: return "Your nearly projects"
            case .recording: return "Record audio with high quality"
            }
        }
        
        var img: UIImage {
            switch self {
            case .newMix: return Asset.imgCreate.image
            case .myMusic: return Asset.imgMusic.image
            case .projects: return Asset.imgCreate.image
            case .recording: return Asset.imgRecording.image
            }
        }
        
    }
    
    // Add here outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Add here your view model
    private var viewModel: HomeVM = HomeVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension HomeVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        self.tableView.register(HomeCell.nib, forCellReuseIdentifier: HomeCell.identifier)
        self.tableView.register(ProjectsCell.nib, forCellReuseIdentifier: ProjectsCell.identifier)
        self.tableView.delegate = self
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        
        Observable.just(ElementHomeCell.allCases).bind(to: tableView.rx.items){(tv, row, item) -> UITableViewCell in
            guard let type = ElementHomeCell(rawValue: row) else {
                fatalError()
            }
            switch type {
            case .projects:
                guard let cell = tv.dequeueReusableCell(withIdentifier: ProjectsCell.identifier, for: IndexPath.init(row: row, section: 0)) as? ProjectsCell else {
                    fatalError()
                }
                cell.dataProjects()
                return cell
            default:
                guard let cell = tv.dequeueReusableCell(withIdentifier: HomeCell.identifier, for: IndexPath.init(row: row, section: 0)) as? HomeCell else {
                    fatalError()
                }
                cell.dataHomeCell(element: item)
                return cell
            }
            
        }.disposed(by: disposeBag)
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
