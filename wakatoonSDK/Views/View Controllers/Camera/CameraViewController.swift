//
//  CameraViewController.swift
//  wakatoonSDK
//
//  Created by bs-mac-4 on 19/12/22.
//

import UIKit
import AVFoundation

class CameraViewController: BaseViewController {
    
    //MARK: - VARIABLES
    var overlay: ArtworkModal?
    var captureSession : AVCaptureSession!
    var backCamera : AVCaptureDevice!
    var backInput : AVCaptureInput!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var stillImageOutput = AVCapturePhotoOutput()
    var isFromEpisodeDrwan:Bool = false
    
    //MARK: - OUTLETS
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var captureBtn: UIButton!
    @IBOutlet weak var overlayIma: UIImageView!
    @IBOutlet weak var cameraContainerView: UIView!
    
    //MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getOverlayImage()
        let backImage = UIImage(named: "close", in: Bundle(for: type(of: self)), compatibleWith: nil)?.imageWithColor(color: .systemTeal)
        closeBtn.setImage(backImage, for: .normal)
        closeBtn.setImage(backImage, for: .highlighted)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.setupAndStartCaptureSession()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }
    
    static func FromStoryBoard() -> Self {
        return  CameraViewController(nibName: "CameraViewController", bundle: Bundle(for: CameraViewController.self)) as! Self
    }
    
    
    //MARK: - BTNS ACTIONS
    @IBAction func closeBtnAction(_ sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: VideoPlayerViewController.self)
    }
    
    @IBAction func captureBtnAction(_ sender: UIButton) {
        #if targetEnvironment(simulator)
            if let image = UIImage(named: "testing", in: Bundle(for: type(of: self)), compatibleWith: nil) {
                Common.saveImageInTemporaryDirectory(image: image, withName: "test.jpg") { url in
                    if let url = url {
                        let loadingVC = LoadingViewController.FromStoryBoard()
                        loadingVC.loadingTitle = "detecting_your_drawing".localized
                        loadingVC.captureImage = url
                        loadingVC.extractImageGet = { model in
                            loadingVC.popViewController(animated: false)
                            let extractionOKVC = ExtractionOKViewController.FromStoryBoard()
                            extractionOKVC.extractedImageModel = model
                            self.pushViewController(view: extractionOKVC)
                        }
                        self.pushViewController(view: loadingVC)
                    }
                }
            }
        #else
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            stillImageOutput.capturePhoto(with: settings, delegate: self)
        #endif
    }
}


//MARK: - CAMERA FUNCTIONS -
extension CameraViewController : AVCapturePhotoCaptureDelegate {
    
    private func setupAndStartCaptureSession(){
        DispatchQueue.global(qos: .userInitiated).async{
            self.captureSession = AVCaptureSession()
            self.captureSession.beginConfiguration()
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            self.setupInputs()
            DispatchQueue.main.async {
                self.setupPreviewLayer()
            }
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    private func setupInputs(){
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            return
        }
        guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
            if WakatoonSDKData.shared.isDebugEnable {
                fatalError("could not create input device from back camera")
            }
            return
        }
        backInput = bInput
        if !captureSession.canAddInput(backInput) {
            if WakatoonSDKData.shared.isDebugEnable {
                fatalError("could not add back camera input to capture session")
            }
        }
        
        captureSession.addInput(backInput)
        
        stillImageOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
    }
    
    private func setupPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill
        previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
        cameraContainerView.layer.addSublayer(previewLayer)
        previewLayer.frame = self.cameraContainerView.bounds
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData)
        else { return }
        Common.saveImageInTemporaryDirectory(image: image.resize(targetSize: CGSize(width: 500, height: 500)).rotate().rotate(radians: .pi), withName: UUID().uuidString+".jpg") { url in
            if let url = url {
                let loadingVC = LoadingViewController.FromStoryBoard()
                loadingVC.loadingTitle = "detecting_your_drawing".localized
                loadingVC.captureImage = url
                loadingVC.extractImageGet = { model in
                    loadingVC.popViewController(animated: false)
                    let extractionOKVC = ExtractionOKViewController.FromStoryBoard()
                    extractionOKVC.extractedImageModel = model
                    self.pushViewController(view: extractionOKVC)
                }
                self.pushViewController(view: loadingVC)
            }
        }
    }
    
}

//MARK: - API CALLING -

extension CameraViewController {
    
    private func getOverlayImage() {
        showLoader()
        DispatchQueue.global(qos: .background).async {
            APIManager.shared.getOverlayImage { response, error in
                if let response = response {
                    self.overlay = Common.decodeDataToObject(data: response)
                    if let overlayIma = self.overlay?.imageUrl, let url = URL(string: overlayIma) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: url) {
                                DispatchQueue.main.async {
                                    self.hideLoader()
                                    self.overlayIma.image = UIImage(data: data)
                                }
                            }
                        }
                    }
                }else {
                    if let error = error as? NSError {
                        let userInfo = error.userInfo
                        DispatchQueue.main.async {
                            self.hideLoader()
                            self.showErrorPopUP(errorModel: userInfo["error"] as? ErrorModel, retry: {})
                        }
                    }
                }
            }
        }
    }
    
}
