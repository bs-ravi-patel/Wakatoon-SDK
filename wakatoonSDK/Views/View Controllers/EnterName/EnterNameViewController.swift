//
//  EnterNameViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 23/12/22.
//

import UIKit

class EnterNameViewController: BaseViewController {

    //MARK: - VARIABLES
    var name: ((_ name: String)->())?
    
    //MARK: - OUTLETS
    @IBOutlet weak var whoTheArtistLbl: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addDoneButtonOnKeyboard()
    }
    
    static func FromStoryBoard() -> Self {
        return  EnterNameViewController(nibName: "EnterNameViewController", bundle: Bundle(for: EnterNameViewController.self)) as! Self
    }

    private func setupView() {
        whoTheArtistLbl.text = "who_the_artist".localized
        cancleBtn.setTitle("cancle".localized, for: .normal)
        continueBtn.setTitle("continue".localized, for: .normal)
        if let name = Common.getPreviousName() {
            nameTF.text = name
        }else {
            nameTF.text = WakatoonSDKData.shared.PROFILE_ID
        }
    }
    
    //MARK: - BTNS ACTIONS
    @IBAction func btnsActions(_ sender: UIButton) {
        if sender.tag == 0 {
            dismiss(animated: true)
        }else {
            if let name = nameTF.text, name.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                Common.setPreviousName(name.trimmingCharacters(in: .whitespacesAndNewlines))
                dismiss(animated: false) {
                    self.name?(name.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        }
    }
    
    func addDoneButtonOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexibleSpace, doneButton]
        nameTF.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        nameTF.resignFirstResponder()
    }
    
}
