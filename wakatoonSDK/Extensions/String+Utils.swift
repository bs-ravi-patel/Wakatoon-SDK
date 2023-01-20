//
//  String+Utils.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 19/12/22.
//

import Foundation
extension String {
    
    var localized: String {
        guard let languageBundle = WakatoonSDKData.shared.selectedLanguageBundel else {return self}
        return NSLocalizedString(self, tableName: nil, bundle: languageBundle, value: "", comment: "")
    }
    
}
