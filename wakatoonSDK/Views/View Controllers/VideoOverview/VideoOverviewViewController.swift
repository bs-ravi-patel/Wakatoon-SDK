//
//  VideoOverviewViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 22/12/22.
//

import UIKit
import MediaPlayer


class VideoOverviewViewController: BaseViewController {

    //MARK: - VARIABLES
    var player: AVPlayer?
    var isEpisodeDrwan:Bool = false
    var isRetakeImage: Bool = false
    var videoModal: VideoGenModal?
    
    //MARK: - OUTLETS
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var retakeBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupPlayer()
        backBtn.setBackButtonLayout(viewController: self)
        let playImage = UIImage(named: "play", in: Bundle(for: type(of: self)), compatibleWith: nil)?.imageWithColor(color: .white)
        playBtn.setImage(playImage, for: .normal)
        playBtn.setImage(playImage, for: .highlighted)
        let cam_retake = UIImage(named: "camera_retake", in: Bundle(for: type(of: self)), compatibleWith: nil)?.imageWithColor(color: .systemTeal)
        retakeBtn.setImage(cam_retake, for: .normal)
        retakeBtn.setImage(cam_retake, for: .highlighted)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player?.pause()
        player = nil
    }
    
    static func FromStoryBoard() -> Self {
        return  VideoOverviewViewController(nibName: "VideoOverviewViewController", bundle: Bundle(for: VideoOverviewViewController.self)) as! Self
    }
    
    //MARK: - BTNS ACTIONS
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        removePlayerNotifations()
        self.navigationController?.popToViewController(ofClass: VideoPlayerViewController.self)
    }
    
    @IBAction func retakeImageAction(_ sender: UIButton) {
        removePlayerNotifations()
        self.navigationController?.popToViewController(ofClass: CameraViewController.self)
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        removePlayerNotifations()
        gotoEnterNameViewController()
    }
    
    //MARK: - SETUP PLAYER
    private func setupPlayer() {
        guard let videoUrlStr = videoModal?.videoUrl, let url = URL(string: videoUrlStr) else {return}
        let playerItem = AVPlayerItem(url: url)
        if let loopTime = videoModal?.loopTimecodeSecond() {
            playerItem.forwardPlaybackEndTime = CMTimeMake(value: Int64(loopTime), timescale: 1)
        }
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerContainerView.layer.addSublayer(playerLayer)
        playerLayer.frame = playerContainerView.bounds
        playerLayer.videoGravity = .resizeAspect
        player?.play()
        addPlayerNotifications()
    }
    
    private func addPlayerNotifications() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [self] _ in
            if let player = player, !player.isPlaying, self.navigationController?.topViewController == self {
                player.play()
            }
        }
    }
    
    private func removePlayerNotifations() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.willEnterForegroundNotification, object: nil)
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
                episodePlayerVC.isEpisodeDrwan = self.isEpisodeDrwan
                episodePlayerVC.isRetakeImage = self.isRetakeImage
                episodePlayerVC.videoUrlStr = url
                self.pushViewController(view: episodePlayerVC)
                Common.downloadEpisodeFromURL(url, isFor: .EPISODE, loopTimecode: loopTime)
            }
            self.pushViewController(view: loadingVC)
        }
        enterNameVC.modalPresentationStyle = .overFullScreen
        enterNameVC.modalTransitionStyle = .crossDissolve
        present(enterNameVC, animated: true)
    }
    
}

