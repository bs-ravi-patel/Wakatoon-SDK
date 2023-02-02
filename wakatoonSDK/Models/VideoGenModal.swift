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
    
    init(videoUrl: String?, videoPlayabilityProgress: Double? = nil, videoGenerationProgress: Double? = nil, videoId: String? = nil, loopTimecode: String?) {
        self.videoUrl = videoUrl
        self.videoPlayabilityProgress = videoPlayabilityProgress
        self.videoGenerationProgress = videoGenerationProgress
        self.videoId = videoId
        self.loopTimecode = loopTimecode
    }
    
    public func loopTimecodeSecond() -> Double? {
        if let loopTimecode = loopTimecode {
            var seconds: Double = 0.0
            
            let df = DateFormatter()
            df.dateFormat = "H:mm:ss:SS"
            if let date = df.date(from: loopTimecode) {
                seconds = Double(Calendar.current.component(.second, from: date))
            }
            
            let timeArr = loopTimecode.components(separatedBy: ":")
            if timeArr.count == 4, let time = Double(timeArr[3]) {
                seconds += time/10
            }
            return seconds
        }
        return nil
    }
    
    
}
