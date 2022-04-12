
//
//  
//  CheckVC.swift
//  Capmix
//
//  Created by haiphan on 12/04/2022.
//
//
import UIKit
import RxCocoa
import RxSwift

class CheckVC: UIViewController {
    
    // Add here outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Add here your view model
    private var viewModel: CheckVM = CheckVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
}
extension CheckVC {
    
    private func setupUI() {
        self.collectionView.register(CheclCLCell.nib, forCellWithReuseIdentifier: CheclCLCell.identifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    private func setupRX() {
//        Observable.just([1,2])
//            .bind(to: self.collectionView.rx.items(cellIdentifier: CheclCLCell.identifier, cellType: CheclCLCell.self)) { row, data, cell in
//            }.disposed(by: disposeBag)
    }
    
}
extension CheckVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheclCLCell.identifier, for: indexPath) as? CheclCLCell else {
            fatalError()
        }
        return cell
    }
    
    
}

extension CheckVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 152, height: 146)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}
