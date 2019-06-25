//
//  ViewController.swift
//  ReverseCamera
//
//  Created by dely on 19/06/2019.
//  Copyright © 2019 dely. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var capturePreviewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
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
}

