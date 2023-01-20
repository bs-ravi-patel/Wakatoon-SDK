//
//  VideoCatchModel.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 13/01/23.
//

import Foundation


struct VideoCatchModel: Codable {
    
    var userID: String?
    var profileID: String?
    var storyID: String?
    var seasonID: Int?
    var episodeId: Int?
    var savedURLString: String?
    var loopTimecode: String?
    
    static func == (lhs: VideoCatchModel, rhs: VideoCatchModel) -> Bool {
        return (lhs.userID == rhs.userID && lhs.profileID == rhs.profileID && lhs.storyID == rhs.storyID && lhs.seasonID == rhs.seasonID && lhs.episodeId == rhs.episodeId)
    }
    
    static func equlsIntroModel(lhs: VideoCatchModel, rhs: VideoCatchModel) -> Bool {
        return (lhs.storyID == rhs.storyID && lhs.seasonID == rhs.seasonID && lhs.episodeId == rhs.episodeId)
    }
    
    public enum CatchFor: String {
        case DETECTED_LOOP_DATA = "DETECTED_LOOP_DATA"
        case EPISODE_DATA       = "EPISODE_DATA"
        case DETECTED_DATA      = "DETECTED_DATA"
    }
    
}

//MARK: - DETECTED_LOOP VIDEO
extension VideoCatchModel {
    
    func isVideoCatched(_ catchFor: CatchFor) -> (Bool,String?,String?) {
        if let episodeCatchModelArr: [VideoCatchModel] = UserDefaults.standard.getObject(forKey: catchFor.rawValue), let catchModel = episodeCatchModelArr.filter({ model in
            return (model.userID == WakatoonSDKData.shared.USER_ID && model.profileID == WakatoonSDKData.shared.PROFILE_ID && model.storyID == WakatoonSDKData.shared.currentStoryID && model.seasonID == WakatoonSDKData.shared.currentSeasonID && model.episodeId == WakatoonSDKData.shared.currentEpisodeID)
        }).first, let catchURLString = catchModel.savedURLString {
            return (true,catchURLString,catchModel.loopTimecode)
        } else {
            return (false,nil,nil)
        }
    }
    
    func saveCatchVideo(_ catchFor: CatchFor, loopTimecode: String?) {
        if var episodeCatchModelArr: [VideoCatchModel] = UserDefaults.standard.getObject(forKey: catchFor.rawValue) {
            if let index = episodeCatchModelArr.firstIndex(where: { catchModel in
                return catchModel == VideoCatchModel(userID: WakatoonSDKData.shared.USER_ID, profileID: WakatoonSDKData.shared.PROFILE_ID, storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID)
            }) {
                var oldModel = episodeCatchModelArr[index]
                oldModel.savedURLString = self.savedURLString
                oldModel.loopTimecode = loopTimecode
                episodeCatchModelArr[index] = oldModel
                UserDefaults.standard.save(episodeCatchModelArr, forKey: catchFor.rawValue)
            } else {
                episodeCatchModelArr.append(VideoCatchModel(userID: WakatoonSDKData.shared.USER_ID, profileID: WakatoonSDKData.shared.PROFILE_ID, storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID, savedURLString: savedURLString, loopTimecode: loopTimecode))
                UserDefaults.standard.save(episodeCatchModelArr, forKey: catchFor.rawValue)
            }
        } else {
            UserDefaults.standard.save([VideoCatchModel(userID: WakatoonSDKData.shared.USER_ID, profileID: WakatoonSDKData.shared.PROFILE_ID, storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID, savedURLString: savedURLString, loopTimecode: loopTimecode)], forKey: catchFor.rawValue)
        }
    }
    
    func removeCatchVideo(_ catchFor: CatchFor) {
        if var episodeCatchModelArr: [VideoCatchModel] = UserDefaults.standard.getObject(forKey: catchFor.rawValue) {
            if let index = episodeCatchModelArr.firstIndex(where: { catchModel in
                return catchModel == VideoCatchModel(userID: WakatoonSDKData.shared.USER_ID, profileID: WakatoonSDKData.shared.PROFILE_ID, storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID)
            }) {
                episodeCatchModelArr.remove(at: index)
                UserDefaults.standard.save(episodeCatchModelArr, forKey: catchFor.rawValue)
            }
        }
    }
    
}

//MARK: - INTRO VIDEO

extension VideoCatchModel {
    
    func isIntroCatched() -> (Bool,String?,String?) {
        if let episodeCatchModelArr: [VideoCatchModel] = UserDefaults.standard.getObject(forKey: "INTRO_CATCH_DATA"), let catchModel = episodeCatchModelArr.filter({ model in
            return (model.storyID == WakatoonSDKData.shared.currentStoryID && model.seasonID == WakatoonSDKData.shared.currentSeasonID && model.episodeId == WakatoonSDKData.shared.currentEpisodeID)
        }).first, let catchURLString = catchModel.savedURLString, let loopTimecode = catchModel.loopTimecode {
            return (true,catchURLString,loopTimecode)
        } else {
            return (false,nil,nil)
        }
    }
    
    func saveIntroCatchVideo(loopTimecode: String?) {
        if var episodeCatchModelArr: [VideoCatchModel] = UserDefaults.standard.getObject(forKey: "INTRO_CATCH_DATA") {
            if let index = episodeCatchModelArr.firstIndex(where: { catchModel in
                return catchModel == VideoCatchModel(storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID)
            }) {
                var oldModel = episodeCatchModelArr[index]
                oldModel.savedURLString = self.savedURLString
                oldModel.loopTimecode = loopTimecode
                episodeCatchModelArr[index] = oldModel
                UserDefaults.standard.save(episodeCatchModelArr, forKey: "INTRO_CATCH_DATA")
            } else {
                episodeCatchModelArr.append(VideoCatchModel(storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID, savedURLString: savedURLString, loopTimecode: loopTimecode))
                UserDefaults.standard.save(episodeCatchModelArr, forKey: "INTRO_CATCH_DATA")
            }
        } else {
            UserDefaults.standard.save([VideoCatchModel(storyID: WakatoonSDKData.shared.currentStoryID, seasonID: WakatoonSDKData.shared.currentSeasonID, episodeId: WakatoonSDKData.shared.currentEpisodeID, savedURLString: savedURLString, loopTimecode: loopTimecode)], forKey: "INTRO_CATCH_DATA")
        }
    }
    
}
