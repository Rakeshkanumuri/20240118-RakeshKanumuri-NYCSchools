//
//  NYCHSTableViewCell.swift
//  20240118-RakeshKanumuri-NYCSchools
//
//  Created by Rakesh kanumuri on 18/01/24.
//

import UIKit



class NYCHSTableViewCell: UITableViewCell {

    // MARK: IBOutlet
    @IBOutlet var cardView: UIView!
    @IBOutlet var sideBarView: UIView!
    
    @IBOutlet var schoolNameLbl: UILabel!
    @IBOutlet var schoolAddrLbl: UILabel!
    @IBOutlet var schoolPhoneNumBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.sideBarView.backgroundColor = UIColor.randomColorForCardViewCell()

        setupCardViewShadows()
        
        self.schoolPhoneNumBtn.layer.cornerRadius = 15
    }
    
    

    
    func setupCardViewShadows(){
        let view = cardView
        view?.layer.cornerRadius = 15.0
        view?.layer.shadowColor = UIColor.black.cgColor
        view?.layer.shadowOffset = CGSize(width: 0, height: 2)
        view?.layer.shadowOpacity = 0.8
        view?.layer.shadowRadius = 3
        view?.layer.masksToBounds = false
    }


}
