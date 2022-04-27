//
//  NearsCell.swift
//  Capmix
//
//  Created by haiphan on 12/04/2022.
//

import UIKit

class NearsCell: UICollectionViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
extension NearsCell {
    
    func loadValue(url: URL) {
        self.lbTitle.text = url.getNameAudio()
        var count: Int = 0
        if let index = RealmManager.shared.getProjects().firstIndex(where: { $0.url == url }) {
            count = Int(RealmManager.shared.getProjects()[index].count)
        }
        self.subTitle.text = "\(Int(url.getDuration()).getTextFromSecond()) \(count) tracks"
    }
}
