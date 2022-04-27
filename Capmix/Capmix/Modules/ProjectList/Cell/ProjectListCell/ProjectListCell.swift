//
//  ProjectListCell.swift
//  Capmix
//
//  Created by haiphan on 15/04/2022.
//

import UIKit

class ProjectListCell: UITableViewCell {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension ProjectListCell {
    
    func loadValue(url: URL) {
        self.lbTitle.text = url.getNameAudio()
        let date = url.creation?.covertToString(format: .ddMMyyyyHHmmss)
        var count: Int = 0
        if let index = RealmManager.shared.getProjectRealm().firstIndex(where: { $0.url == url }) {
            count = RealmManager.shared.getProjectRealm()[index].count
        }
        self.subTitle.text = "\(Int(url.getDuration()).getTextFromSecond()) \(count) tracks \(date ?? "")"
    }
}
