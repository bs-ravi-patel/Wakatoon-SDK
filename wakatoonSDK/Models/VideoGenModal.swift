//
//  VideoGenModal.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 22/12/22.
//

import Foundation


struct VideoGenModal: Codable {
    let videoUrl: String?
    let videoPlayabilityProgress: Double?
    let videoGenerationProgress: Double?
    let videoId: String?
    let loopTimecode: String?
    
    init(videoUrl: String?, videoPlayabilityProgress: Double?, videoGenerationProgress: Double?, videoId: String?, loopTimecode: String?) {
        self.videoUrl = videoUrl
        self.videoPlayabilityProgress = videoPlayabilityProgress
        self.videoGenerationProgress = videoGenerationProgress
        self.videoId = videoId
        self.loopTimecode = loopTimecode
    }
    
    public func loopTimecodeSecond() -> Int? {
        if let loopTimecode = loopTimecode {
            let df = DateFormatter()
            df.dateFormat = "H:mm:ss:SS"
            if let date = df.date(from: loopTimecode) {
                return Calendar.current.component(.second, from: date)
            }
        }
        return nil
    }
    
    
}
