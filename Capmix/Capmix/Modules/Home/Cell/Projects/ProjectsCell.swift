//
//  ProjectsCell.swift
//  Capmix
//
//  Created by haiphan on 12/04/2022.
//

import UIKit
import RxSwift
import RxCocoa

class ProjectsCell: BaseTableViewCell {
    
    struct Constant {
        static let positionX: CGFloat = 0
        static let positionY: CGFloat = 22
        static let blur: CGFloat = 54
        static let spread: CGFloat = 0
    }

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var heightCollection: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.shadowView.layer.applySketchShadow(color: Asset.backOpacity60.color, alpha: 1, x: Constant.positionX, y: Constant.positionY, blur: Constant.blur, spread: Constant.spread)
        self.setupUI()
        self.setupRX()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension ProjectsCell {
    
    private func setupUI() {
        self.collectionView.register(NearsCell.self, forCellWithReuseIdentifier: NearsCell.identifier)
        self.collectionView.delegate = self
    }
    
    private func setupRX() {
        Observable.just([1,2])
            .bind(to: self.collectionView.rx.items(cellIdentifier: NearsCell.identifier, cellType: NearsCell.self)) { row, data, cell in
            }.disposed(by: disposeBag)
    }
    
    func dataProjects() {
        self.heightCollection.constant = 146
    }
    
}
extension ProjectsCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
