//
//  ViewController.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 18/12/2018.
//  Copyright © 2018 Thomas Bale. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import GLKit
import CoreData


class ARMarkerViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    // Database initialisation
    var container: NSPersistentContainer!
    
    var captureNextFrame = false
    var barcode = String()
    var barcodeFound = false
    
    @IBOutlet var sceneView: ARSCNView!
    
    // Button press used to prevent process overload & button for loading a tray scene
    @IBOutlet var buttonpress: [UIButton]!
    

    @IBOutlet weak var Debuggingop: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Limit FPS
        sceneView.preferredFramesPerSecond = 30
        Debuggingop.text = "localising"
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
    
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showWireframe, .showBoundingBoxes, .showFeaturePoints]
        
        // setup button targets
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()

        
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    // when the button is pressed
    @IBAction func pressed(_ sender: Any) {
        
        if barcodeFound == true{
            self.performSegue(withIdentifier: "barcodeFoundARView", sender: self)
        }
        
        captureNextFrame = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // Calls every time a frame is updated in the session
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        
        if captureNextFrame {
            barcode = detectBarcode(pixelbffer: pixelBuffer)
            if barcode != ""{
                captureNextFrame = false
                barcodeFound = true
                self.performSegue(withIdentifier: "barcodeFoundARView", sender: self)
            }
        }
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if (segue.destination is EventTableViewController) && (barcodeFound == true)
        {
            let vc = segue.destination as? EventTableViewController
            // pass over the specific task for action
            let selection = barcode
            vc?.barcodeLocation = selection
        }
    }
    
    
}

