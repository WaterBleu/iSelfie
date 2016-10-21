//
//  ViewController.swift
//  iSelfie
//
//  Created by Jeff Huang on 2016-10-20.
//  Copyright © 2016 HeartCore. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var cameraView: UIView!
    var captureSession = AVCaptureSession();
    var sessionOutput = AVCapturePhotoOutput();
    var previewLayer = AVCaptureVideoPreviewLayer();
    var photoTaken = false;
    var photoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo);

    override func viewWillAppear(_ animated: Bool) {
        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInDuoCamera, AVCaptureDeviceType.builtInTelephotoCamera,AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.unspecified)
        for device in (deviceDiscoverySession?.devices)! {
            if(device.position == AVCaptureDevicePosition.front){
                do{
                    photoDevice = device;
                    let input = try AVCaptureDeviceInput(device: device)
                    if(captureSession.canAddInput(input)){
                        captureSession.addInput(input);
                        captureSession.startRunning();
                        if(captureSession.canAddOutput(sessionOutput)){
                            captureSession.addOutput(sessionOutput);
                            sessionOutput.capturePhoto(with: AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG]), delegate: self);
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
                            //previewLayer.connection.videoScaleAndCropFactor = previewLayer.connection.videoMaxScaleAndCropFactor
                            //captureSession.commitConfiguration();
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait;
                            cameraView.layer.addSublayer(previewLayer);
                        }
                    }
                }
                catch{
                    print("exception!");
                }
            }
        }
    }
    
    @IBAction func zoom(_ sender: UIPinchGestureRecognizer) {
        var zoomFactor = sender.scale;
        var currentZoom = photoDevice!.videoZoomFactor;
        var increment = zoomFactor - 1;

        do {
            try photoDevice!.lockForConfiguration();
            defer {photoDevice!.unlockForConfiguration()}
            if(zoomFactor > 1){
                if(zoomFactor > currentZoom && currentZoom + increment < photoDevice!.activeFormat.videoMaxZoomFactor){
                    photoDevice!.videoZoomFactor += increment;
                }
                else if(zoomFactor < currentZoom && currentZoom + increment < photoDevice!.activeFormat.videoMaxZoomFactor){
                    photoDevice!.videoZoomFactor += increment;
                }
            }
            else if(zoomFactor < 1){
                if(currentZoom + increment > 1){
                    photoDevice!.videoZoomFactor += increment;
                }
                else{
                    photoDevice!.videoZoomFactor = 1;
                }
            }
            else{
                photoDevice!.videoZoomFactor = 1
            }
        }
        catch{
            print("error");
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        previewLayer.frame = cameraView.bounds
        previewLayer.position = CGPoint(x: self.cameraView.frame.width/2, y: self.cameraView.frame.height/2)
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if(error != nil){
            print(error?.localizedDescription);
        }
        else{
            if(photoTaken){
                let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer);
                UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData!)!, nil, nil, nil);
                photoTaken = false;
            }
        }
    }

    @IBAction func cameraButton(_ sender: UIButton) {
        photoTaken = true;
        sessionOutput.capturePhoto(with: AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG]), delegate: self);
    }
    
    @IBAction func photolibraryButton(_ sender: UIButton) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)){
            let imagePicker = UIImagePickerController();
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true;
            self.present(imagePicker, animated: true, completion: nil);
        }
    }
}

