//
//  HomeCell.swift
//  Capmix
//
//  Created by haiphan on 11/04/2022.
//

import UIKit

class HomeCell: BaseTableViewCell {
    
    struct Constant {
        static let positionX: CGFloat = 0
        static let positionY: CGFloat = 22
        static let blur: CGFloat = 54
        static let spread: CGFloat = 0
    }

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbSubtitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.shadowView.layer.applySketchShadow(color: Asset.backOpacity60.color, alpha: 1, x: Constant.positionX, y: Constant.positionY, blur: Constant.blur, spread: Constant.spread)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension HomeCell {
    func dataHomeCell(element: HomeVC.ElementHomeCell) {
        self.lbTitle.text = element.title
        self.lbSubtitle.text = element.subTitle
        self.img.image = element.img
    }
}
