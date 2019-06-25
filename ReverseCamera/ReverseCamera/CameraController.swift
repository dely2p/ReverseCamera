//
//  CameraController.swift
//  ReverseCamera
//
//  Created by dely on 26/06/2019.
//  Copyright © 2019 dely. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController {

    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        DispatchQueue(label: "prepare").async {
            do {
                self.createCaptureSession()
                try self.configureCaptureDevices()
                try self.configureDeviceInputs()
                try self.configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func createCaptureSession() {
        self.captureSession = AVCaptureSession()
    }
    
    func configureCaptureDevices() throws {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        let cameras = session.devices.compactMap{$0}
        if cameras.isEmpty { throw CameraControllerError.noCamerasAvailable }
        
        for camera in cameras {
            if camera.position == .front {
                self.frontCamera = camera
            }
            
            if camera.position == .back {
                self.rearCamera = camera
                
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
        }
    }
    
    func configureDeviceInputs() throws {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        if let rearCamera = self.rearCamera {
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
            self.currentCameraPosition = .rear
        }else if let frontCamera = self.frontCamera {
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
            else { throw CameraControllerError.inputsAreInvalid }
            self.currentCameraPosition = .front
        }else { throw CameraControllerError.noCamerasAvailable }
    }
    
    func configurePhotoOutput() throws {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        self.photoOutput = AVCapturePhotoOutput()
        self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
        
        if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
        
        captureSession.startRunning()
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings()
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
}

extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
        else if let imageData = photo.fileDataRepresentation() {
            if let image = UIImage(data: imageData) {
                self.photoCaptureCompletionBlock?(image, nil)
            }
        }else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
        
    }
}
