//
//  ViewController.swift
//  DrawsCameraAsBackgoundWithSceneKit
//
//  Created by Judson Douglas on 11/14/14.
//  Copyright (c) 2014 Judson Douglas. All rights reserved.
//
import UIKit
import SceneKit
import AVFoundation

class Video_ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //capture video input in an AVCaptureLayerVideoPreviewLayer
        let captureSession = AVCaptureSession()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        if let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) {
            var err: NSError? = nil
            if let videoIn : AVCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: &err) as? AVCaptureDeviceInput {
                if(err == nil){
                    if (captureSession.canAddInput(videoIn as AVCaptureInput)){
                        captureSession.addInput(videoIn as AVCaptureDeviceInput)
                    }
                    else {
                        println("Failed add video input.")
                    }
                }
                else {
                    println("Failed to create video input.")
                }
            }
            else {
                println("Failed to create video capture device.")
            }
        }
        captureSession.startRunning()
        
        //add AVCaptureVideoPreviewLayer as sublayer of self.view.layer
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)
        
        //create a SceneView with a clear background color and add it as a subview of self.view
        let sceneView = SCNView()
        sceneView.frame = self.view.bounds
        sceneView.backgroundColor = UIColor.clearColor()
        previewLayer.frame = self.view.bounds
        self.view.addSubview(sceneView)
        
        //now you could begin to build your scene with the device's camera video as your background
        let scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        let boxGeometry = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 1.0)
        let boxNode = SCNNode(geometry: boxGeometry)
        scene.rootNode.addChildNode(boxNode)
        sceneView.scene = scene
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
}
