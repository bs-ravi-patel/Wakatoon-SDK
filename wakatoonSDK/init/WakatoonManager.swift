//
//  WakatoonManager.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 09/12/22.
//

import Foundation
import UIKit

public class WakatoonSDK: NSObject {
    
    public var delegate: WakatoonSDKDelegate? {
        didSet {
            WakatoonSDKData.shared.delegate = delegate
        }
    }
    
    override init() {}
    
    public class Builder {
        
        public var instance: WakatoonSDK?
        
        public init(instance: WakatoonSDK? = nil) {
            self.instance = instance
        }
        
        /// create the build
        public func build() -> WakatoonSDK {
            setupLanguageBundel()
            UIFont().registerFonts()
            return instance ?? WakatoonSDK()
        }
        
        /// setup SDK with API Key for API Authentication
        /// USER_ID for users id
        /// PROFILE_ID for user profiles id
        public func initSDK(API_KEY: String, USER_ID: String, PROFILE_ID:String) -> Builder {
            WakatoonSDKData.shared.API_KEY = API_KEY
            WakatoonSDKData.shared.USER_ID = USER_ID
            WakatoonSDKData.shared.PROFILE_ID = PROFILE_ID
            return self
        }
        
        public func enableDebugMode(_ isEnable: Bool) -> Builder {
            WakatoonSDKData.shared.isDebugEnable = isEnable
            return self
        }
        
        public func setLanguage(_ language: Language) -> Builder {
            WakatoonSDKData.shared.selectedLanguage = language
            return self
        }
        
        private func setupLanguageBundel() {
            guard let bundle = Bundle(identifier: WakatoonSDKData.shared.BundelID), let languagePath = bundle.path(forResource: WakatoonSDKData.shared.selectedLanguage.description(), ofType: "lproj"), let languageBundle = Bundle(path: languagePath) else {
                return
            }
            WakatoonSDKData.shared.selectedLanguageBundel = languageBundle
        }
        
    }
    
    /// Set Profile ID
    public func setProfile( PROFILE_ID:String, completion: @escaping((_ isUpdated: Bool)->())) {
        WakatoonSDKData.shared.PROFILE_ID = PROFILE_ID
        completion(true)
    }
    
    /// Set User ID
    public func setUser(USER_ID:String, completion: @escaping((_ isUpdated: Bool)->())) {
        WakatoonSDKData.shared.USER_ID = USER_ID
        completion(true)
    }
    
    /// Display the SDK Terms and Condition Pop with completion of acceptance result
    public func showEulaConfirmationPopUP(controller: UINavigationController, completion: @escaping((_ isAccept: Bool)->())) {
        let videoPlayerList = eulaSDKPopUPViewController(nibName: "eulaSDKPopUPViewController", bundle: Bundle(for: eulaSDKPopUPViewController.self))
        videoPlayerList.callBack = { isAccept in
            videoPlayerList.dismiss(animated: false)
            completion(isAccept)
        }
        videoPlayerList.modalPresentationStyle = .overFullScreen
        videoPlayerList.modalTransitionStyle = .crossDissolve
        controller.present(videoPlayerList, animated: true)
    }
    
    /// GET the artwork of the episode
    public func getTheArtwork(storyID: String, seasonID: Int, episodeId: Int, completion: @escaping((_ responce: Data?, _ error: Error?)->())) {
        APIManager.shared.getArtWork(storyID: storyID, seasonID: seasonID, episodeId: episodeId, completion: completion)
    }
    
    /// Goto Video Player
    public func gotoVideoPreview(controller: UINavigationController, storyID: String, seasonID: Int, episodeId: Int, totalEpisodes: Int) {
        WakatoonSDKData.shared.currentStoryID = storyID
        WakatoonSDKData.shared.currentSeasonID = seasonID
        WakatoonSDKData.shared.currentEpisodeID = episodeId
        WakatoonSDKData.shared.totalEpisode = totalEpisodes
        let videoPlayerController = VideoPlayerViewController.FromStoryBoard()
        videoPlayerController.isScreenFor = EpisodeDrawnModel().isEpisodeDrawn() ? .DETECTED_LOOP : .INTRO
        controller.navigationBar.isHidden = true
        controller.pushViewController(videoPlayerController, animated: true)
    }
    
    /// Set Video Genration True/False Hardcoded
    ///  Defualt value set as False
    public func setVideoGeneration(_ set: Bool) {
        WakatoonSDKData.shared.isForceVideoGeneration = set
    }
    
    ///GET all suppotedLanguage of SDK on 0
    ///GET currentSelected Language of SDK on 1
    public func getAllSupportedLanguage() -> ([String],String) {
        var temp = [String]()
        Language.allCases.forEach({ lang in
            temp.append(lang.description())
        })
        return (temp,WakatoonSDKData.shared.selectedLanguage.description())
    }
    
    ///SET SDK language Defualt will be fr
    public func setLanguage(_ language: Language) {
        WakatoonSDKData.shared.selectedLanguage = language
    }
    
    ///SET Profile Name
    public func setProfileName(name: String) {
        Common.setPreviousName(name)
    }
    
}

public protocol WakatoonSDKDelegate {
    func invalidAPIKey()
    func videoPlaybackStarted()
    func videoPlaybackStopped()
}
