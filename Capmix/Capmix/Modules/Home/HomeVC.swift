
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
        self.tableView.delegate = self
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        Observable.just([1,2])
            .bind(to: tableView.rx.items(cellIdentifier: HomeCell.identifier, cellType: HomeCell.self)) {(row, element, cell) in
            }.disposed(by: disposeBag)
    }
}
extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
