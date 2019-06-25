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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() { }
        func configureCaptureDevices() throws { }
        func configureDeviceInputs() throws { }
        func configurePhotoOutput() throws { }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
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

}
