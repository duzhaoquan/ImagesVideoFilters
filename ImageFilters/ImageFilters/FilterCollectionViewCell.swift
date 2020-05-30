//
//  FilterCollectionViewCell.swift
//  ImageFilters
//
//  Created by dzq_mac on 2020/5/28.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {

    var cellData :FilterData?{
        didSet{
            nameLabel.text = cellData?.name
            
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
