//
//  LoadingViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 20/12/22.
//

import UIKit

class LoadingViewController: BaseViewController {
    
    //MARK: - VARIABLES
    var captureImage: URL? {
        didSet {
            DispatchQueue.global(qos: .background).async {
                self.extractImageAPICall()
            }
        }
    }
    var loadingTitle = String()
    var extractedImageModel:ExtractImageModal?
    var extractImageGet: ((_ extractedImageModel: ExtractImageModal?)->())?
    
    var isForPrepareCartoonOverview: Bool = false
    var videoModal: VideoGenModal?
    var overviewVideoCreate: ((_ videoModal: String, _ loopTimecode: String?)->())?
    
    var isForPrepareEpisode: Bool = false
    var name = String()
    
    //MARK: - OUTLETS
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var percentLbl: UILabel!
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    static func FromStoryBoard() -> Self {
        return  LoadingViewController(nibName: "LoadingViewController", bundle: Bundle(for: LoadingViewController.self)) as! Self
    }
    
    private func setupView() {
        titleLbl.text = loadingTitle
        titleLbl.font = getFont(size: 17, style: .Medium)
        percentLbl.font = getFont(size: 13, style: .Medium)
        percentLbl.isHidden = true
        if isForPrepareCartoonOverview {
            percentLbl.isHidden = false
            percentLbl.text = "0 %"
            createVideo(isFormGen: true, lable: .DETECTED)
        }
        if isForPrepareEpisode {
            percentLbl.isHidden = false
            percentLbl.text = "0 %"
            createVideo(isFormGen: true, lable: .EPISODE, name: name)
        }
    }
    
    
}

//MARK: - API CALLING -
extension LoadingViewController {
    
    private func extractImageAPICall() {
        guard let captureImage = captureImage else {return}
        APIManager.shared.getExtractedImage(image: captureImage) { response, error in
            if let response = response {
                self.extractedImageModel = Common.decodeDataToObject(data: response)
                if let isSuccess = self.extractedImageModel?.extractionSucceeded, isSuccess {
                    DispatchQueue.main.async {
                        self.extractImageGet?(self.extractedImageModel)
                    }
                } else {
                    let error = ErrorModel(errorMessage: "artwork_not_found".localized, errorType: "artwork_error".localized)
                    DispatchQueue.main.async {
                        self.showErrorPopUP(errorModel: error,isCancleShow: false, isRetryShow: true, retry: {
                            self.popViewController()
                        })
                    }
                }
            } else {
                if let error = error as? NSError {
                    let userInfo = error.userInfo
                    var error = userInfo["error"] as? ErrorModel
                    if let errorType = error?.errorType, errorType == "ArtworkExtractionError" {
                        error?.errorType = "artwork_extraction_error".localized
                    }else {
                        error?.errorType = "artwork_error".localized
                    }
                    error?.errorMessage = "artwork_not_found".localized
                    DispatchQueue.main.async {
                        self.showErrorPopUP(errorModel: error,isCancleShow: false, isRetryShow: true, retry: {
                            self.popViewController()
                        })
                    }
                }
            }
        }
    }
    
    private func createVideo(isFormGen: Bool? = nil, lable: APIManager.VideoLabel, name: String? = nil) {
        APIManager.shared.getVideo(isForceGen: isFormGen, label: lable, name: name) { response, error in
            if let response = response {
                self.videoModal = Common.decodeDataToObject(data: response)
                if let url = self.videoModal?.videoUrl, let genPercent = self.videoModal?.videoPlayabilityProgress {
                    DispatchQueue.main.async { [self] in
                        let value = Int(round(genPercent * 100))
                        percentLbl.text = "\(value) %"
                        if value == 100 {
                            self.overviewVideoCreate?(url, self.videoModal?.loopTimecode)
                        }else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.createVideo(lable: lable, name: name)
                            }
                        }
                    }
                }
            } else {
                if let error = error as? NSError {
                    let userInfo = error.userInfo
                    DispatchQueue.main.async {
                        self.showErrorPopUP(errorModel: userInfo["error"] as? ErrorModel,isCancleShow: false, isRetryShow: true, retry: {
                            self.popViewController()
                        })
                    }
                }
            }
        }
    }
    
}
