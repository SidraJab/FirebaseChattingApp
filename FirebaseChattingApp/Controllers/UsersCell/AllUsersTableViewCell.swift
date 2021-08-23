//
//  AllUsersTableViewCell.swift
//  FirebaseChattingApp
//
//  Created by Sidra Jabeen on 20/08/2021.
//

import UIKit

class AllUsersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var viewAdd: UIView!
    @IBOutlet weak var btnAdd: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewAdd.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
