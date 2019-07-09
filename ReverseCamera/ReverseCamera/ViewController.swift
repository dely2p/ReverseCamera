//
//  ViewController.swift
//  ReverseCamera
//
//  Created by dely on 19/06/2019.
//  Copyright © 2019 dely. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var capturePreviewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var toggleCameraButton: UIButton!
    let cameraController = CameraController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCameraController()
        makeCaptureButton()
    }

    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.capturePreviewView)
        }
    }
    
    func makeCaptureButton() {
        captureButton.layer.borderColor = UIColor.black.cgColor
        captureButton.layer.borderWidth = 2
        
        captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    
    @IBAction func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        }
            
        catch {
            print(error)
        }
        
        switch cameraController.currentCameraPosition {
        case .some(.front):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Front Camera Icon"), for: .normal)
            
        case .some(.rear):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Rear Camera Icon"), for: .normal)
            
        case .none:
            return
        }
    }
}

