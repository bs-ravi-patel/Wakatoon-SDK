//
//  VideoPlayerViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 12/01/23.
//

import UIKit
import AVFoundation

class VideoPlayerViewController: BaseViewController {
    
    //MARK: - VARIABLES
    public var isScreenFor = APIManager.VideoLabel.INTRO
    private var videoModal: VideoGenModal? {
        didSet {
            DispatchQueue.main.async {
                self.setupPlayer()
            }
        }
    }
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    //MARK: - OUTLETS
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var cameraRetakeButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var loader: SpinnerView!
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        WakatoonSDKData.shared.nextEpisodeDelegate = self
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let player = player, !player.isPlaying {
            player.play()
        }
    }
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async { [self] in
            playerLayer?.frame = playerContainerView.bounds
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removePlayerNotifations()
        player?.pause()
    }
    
    static func FromStoryBoard() -> Self {
        return  VideoPlayerViewController(nibName: "VideoPlayerViewController", bundle: Bundle(for: VideoPlayerViewController.self)) as! Self
    }
    
    private func setupView() {
        backButton.setBackButtonLayout(viewController: self)
        if isScreenFor == .INTRO {
            playButton.isHidden = true
            cameraRetakeButton.isHidden = true
            cameraButton.isHidden = false
            loader.isHidden = false
            let catchResult = VideoCatchModel().isIntroCatched()
            if catchResult.0, let catchURL = catchResult.1, !WakatoonSDKData.shared.isForceVideoGeneration {
                self.videoModal = VideoGenModal(videoUrl: catchURL, videoPlayabilityProgress: nil, videoGenerationProgress: nil, videoId: nil, loopTimecode: catchResult.2)
                loader.isHidden = true
            } else {
                DispatchQueue.global(qos: .background).async {
                    self.createVideo(isForceGen: true, lable: .INTRO)
                }
            }
        } else if isScreenFor == .DETECTED_LOOP {
            playButton.isHidden = false
            cameraRetakeButton.isHidden = false
            cameraButton.isHidden = true
            loader.isHidden = false
            let playImage = UIImage(named: "play", in: Bundle(for: type(of: self)), compatibleWith: nil)?.imageWithColor(color: .systemTeal)
            playButton.setImage(playImage, for: .normal)
            playButton.setImage(playImage, for: .highlighted)
            let cam_retake = UIImage(named: "camera_retake", in: Bundle(for: type(of: self)), compatibleWith: nil)?.imageWithColor(color: .white)
            cameraRetakeButton.setImage(cam_retake, for: .normal)
            cameraRetakeButton.setImage(cam_retake, for: .highlighted)
            let catchResult = VideoCatchModel().isVideoCatched(.DETECTED_LOOP_DATA)
            if catchResult.0, let catchURL = catchResult.1, !WakatoonSDKData.shared.isForceVideoGeneration {
                self.videoModal = VideoGenModal(videoUrl: catchURL, videoPlayabilityProgress: nil, videoGenerationProgress: nil, videoId: nil, loopTimecode: catchResult.2)
                loader.isHidden = true
            } else {
                DispatchQueue.global(qos: .background).async {
                    self.createVideo(isForceGen: true, lable: .DETECTED_LOOP)
                }
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NEW_IMAGE_SELECT"), object: nil, queue: .main) { _ in
            if self.isScreenFor == .DETECTED_LOOP {
                DispatchQueue.global(qos: .background).async {
                    self.player = nil
                    self.playerContainerView.layer.sublayers?.forEach({ layer in
                        layer.removeFromSuperlayer()
                    })
                    self.createVideo(isForceGen: true, lable: .DETECTED_LOOP)
                }
            }
        }
    }
    
    //MARK: - BTNS ACTIONS
    
    @IBAction func cameraAction(_ sender: UIButton) {
        Common.isCameraPermissionGranted { isGranted in
            DispatchQueue.main.async {
                if isGranted {
                    self.pushViewController(view: CameraViewController.FromStoryBoard())
                } else {
                    self.pushViewController(view: CameraPermissionViewController.FromStoryBoard())
                }
            }
        }
    }

    @IBAction func cameraRetakeAction(_ sender: UIButton) {
        Common.isCameraPermissionGranted { isGranted in
            DispatchQueue.main.async {
                if isGranted {
                    let CameraVC = CameraViewController.FromStoryBoard()
                    CameraVC.isFromEpisodeDrwan = true
                    self.pushViewController(view: CameraVC)
                } else {
                    self.pushViewController(view: CameraPermissionViewController.FromStoryBoard())
                }
            }
        }
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        gotoEnterNameViewController()
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        removePlayerNotifations()
        popViewController()
    }
    
    //MARK: - SETUP PLAYER
    private func setupPlayer() {
        if let viewController = UIViewController.topMostViewController(), viewController.isKind(of: VideoPlayerViewController.self) {
            guard let videoUrlStr = videoModal?.videoUrl , let url = URL(string: videoUrlStr) else {return}
            
            if let loopTime = videoModal?.loopTimecodeSecond() {
                let playerItem = AVPlayerItem(url: url)
                playerItem.forwardPlaybackEndTime = CMTimeMake(value: Int64(loopTime), timescale: 1)
                player = AVPlayer(playerItem: playerItem)
            } else {
                player = AVPlayer(url: url)
            }
            
            playerLayer = AVPlayerLayer(player: player)
            playerContainerView.layer.sublayers?.forEach({ layer in
                layer.removeFromSuperlayer()
            })
            playerContainerView.layer.addSublayer(playerLayer ?? AVPlayerLayer())
            playerLayer?.frame = playerContainerView.frame
            playerLayer?.frame.origin = .zero
            playerLayer?.videoGravity = .resizeAspect
            playerContainerView.layoutIfNeeded()
            playerLayer?.layoutIfNeeded()
            
            player?.play()
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { [weak self] _ in
                self?.player?.seek(to: CMTime.zero)
                self?.player?.play()
            }
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [self] _ in
                if let player = player, !player.isPlaying, self.navigationController?.topViewController == self {
                    player.play()
                }
            }
        } else {
            self.player?.pause()
        }
    }
    
    private func removePlayerNotifations() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.willEnterForegroundNotification, object: nil)
    }
    

    private func catchVideo(urlString: String, isFor: APIManager.VideoLabel, loopTimecode: String?) {
        Common.downloadEpisodeFromURL(urlString, isFor: isFor, loopTimecode: loopTimecode)
    }
    
    private func gotoEnterNameViewController() {
        let enterNameVC = EnterNameViewController.FromStoryBoard()
        enterNameVC.name = { name in
            let loadingVC = LoadingViewController.FromStoryBoard()
            loadingVC.isForPrepareEpisode = true
            loadingVC.name = name
            loadingVC.loadingTitle = "preparing_your_cartoon".localized
            loadingVC.overviewVideoCreate = { url, loopTime in
                loadingVC.popViewController(animated: false)
                let episodePlayerVC = EpisodePlayerViewController.FromStoryBoard()
                episodePlayerVC.videoUrlStr = url
                self.pushViewController(view: episodePlayerVC)
                self.catchVideo(urlString: url, isFor: .EPISODE, loopTimecode: loopTime)
            }
            self.pushViewController(view: loadingVC)
        }
        enterNameVC.modalPresentationStyle = .overFullScreen
        enterNameVC.modalTransitionStyle = .crossDissolve
        present(enterNameVC, animated: true)
    }
    
}

extension VideoPlayerViewController {
    
    private func createVideo(isForceGen: Bool? = nil, lable: APIManager.VideoLabel, name: String? = nil) {
        APIManager.shared.getVideo(isForceGen: isForceGen, label: lable, name: name) { response, error in
            DispatchQueue.main.async {
                if let response = response {
                    let model:VideoGenModal? = Common.decodeDataToObject(data: response)
                    if model?.videoUrl != nil, let genPercent = model?.videoPlayabilityProgress {
                        let value = Int(round(genPercent * 100))
                        if value == 100 {
                            self.loader.isHidden = true
                            self.videoModal = model
                            self.catchVideo(urlString: model?.videoUrl ?? "", isFor: lable, loopTimecode: model?.loopTimecode)
                        }else {
                            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now()+1, execute: {
                                self.createVideo(lable: lable, name: name)
                            })
                        }
                    }
                } else if let error = error as? NSError {
                    let userInfo = error.userInfo
                    self.showErrorPopUP(errorModel: userInfo["error"] as? ErrorModel,isCancleShow: false, isRetryShow: true, retry: {
                        self.popViewController()
                    })
                }
            }
        }
    }
    
}

extension VideoPlayerViewController: NextPlayEpisodeDelegate {
    
    func playNextEpisode() {
        self.navigationController?.popToViewController(ofClass: VideoPlayerViewController.self, animated: false)
        WakatoonSDKData.shared.currentEpisodeID += 1
        loader.isHidden = false
        self.isScreenFor = EpisodeDrawnModel().isEpisodeDrawn() ? .DETECTED_LOOP : .INTRO
        self.player = nil
        self.playerContainerView.layer.sublayers?.forEach({ layer in
            layer.removeFromSuperlayer()
        })
        self.setupView()
    }
    
    func backFromEpisode() {
        self.navigationController?.popToViewController(ofClass: VideoPlayerViewController.self)
        if self.isScreenFor == .DETECTED_LOOP {
            if let player = self.player {
                player.seek(to: .zero)
                player.play()
            }
        } else if self.isScreenFor == .INTRO {
            self.player = nil
            self.playerContainerView.layer.sublayers?.forEach({ layer in
                layer.removeFromSuperlayer()
            })
            self.isScreenFor = .DETECTED_LOOP
            self.setupView()
        }
    }
    
}
