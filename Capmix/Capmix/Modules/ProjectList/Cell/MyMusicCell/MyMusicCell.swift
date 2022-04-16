//
//  MyMusicCell.swift
//  Capmix
//
//  Created by haiphan on 15/04/2022.
//

import UIKit
import EasyBaseAudio

class MyMusicCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension MyMusicCell {
    
    func loadValue(url: URL) {
        self.lbTitle.text = url.getNameAudio()
        let date = url.creation?.covertToString(format: .ddMMyyyyHHmmss)
        self.subTitle.text = "\(Int(url.getDuration()).getTextFromSecond()) \(date ?? "")"
    }
    
}
