//
//  eulaSDKPopUPViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 15/12/22.
//

import UIKit


class eulaSDKPopUPViewController: UIViewController {

    //MARK: - VARIABLES
    var callBack: ((_ isAccept: Bool)->())?
    
    //MARK: - OUTLETS
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    @IBOutlet weak var checkUncheckBtn: UIButton!
    @IBOutlet weak var termsLbl: UILabel!
    
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    
    private func setupView() {
        titleLbl.text = "eula_sdk_popup_title".localized
        termsLbl.text = "eula_sdk_popup_condition".localized
        descLbl.text = "eula_sdk_popup_description".localized
        
        titleLbl.font = getFont(size: 15, style: .Regular)
        termsLbl.font = getFont(size: 12, style: .Regular)
        descLbl.font = getFont(size: 12, style: .Regular)
        
        termsLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelClicked(_:))))
        checkUncheckBtn.isSelected = false
        checkUncheckBtn.setImage(UIImage(named: "\(checkUncheckBtn.isSelected ? "checkbox" : "unchecked")", in: Bundle(for: type(of: self)), compatibleWith: nil)!, for: .normal)
        checkUncheckBtn.tintColor = isDarkMode() ? .white : .black
    }
    @objc func labelClicked(_ sender: Any) {
    }
    
    //MARK: - BTNS ACTIONS
   
    @IBAction func continueBtnAction(_ sender: UIButton) {
        if checkUncheckBtn.isSelected, let callBack = callBack {
            callBack(true)
        }
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        if let callBack = callBack {
            callBack(false)
        }
    }
    
    @IBAction func checkUncheckBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setImage(UIImage(named: "\(sender.isSelected ? "checkbox" : "unchecked")", in: Bundle(for: type(of: self)), compatibleWith: nil)!, for: .normal)
        sender.tintColor = isDarkMode() ? .white : .black
    }
    
}

