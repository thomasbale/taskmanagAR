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
import CoreVideo

//let MARKER_SIZE_IN_METERS : CGFloat = 0.0282; //set this to size of physically med marker in meters

typealias marker_seen = (transform: SCNMatrix4, visible_in_frame: Bool)

protocol DisplayViewControllerDelegate : NSObjectProtocol{
     func updateEvent(activeEvents: [Task])
}



class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    weak var delegate : DisplayViewControllerDelegate?
    var detectionQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
    ".serialSceneKitQueue")

    // UI interface for marker detection work
    @IBOutlet weak var completeTick: UIImageView!
    @IBOutlet weak var findMarkerLayer: UIImageView!
    @IBOutlet weak var markerFound1: UIImageView!
    @IBOutlet weak var markerFound2: UIImageView!
    @IBOutlet weak var markerFound3: UIImageView!

    // All the tasks in the set - this allows progression backwards and forwards
    var activeTasks = [Task()]
    var currentTask = Task()
    // instructions
    var vc = InstructionViewController()
    // The index of the current task
    var taskIndex = Int()
    // Localised nodes for this session based on marker target transformation
    private var localizedContentNode = SCNNode()
    // localsed from the space
    private var TrayCentrepoint = SCNNode()
    // status variables
    private var isLocalized = false
    private var captureNextFrameForCV = true; //when set to true, frame is processed by opencv for marker
    private var dispatchProcesscomplete = true; //for threading main que
    // Framerate limiting and localisations settings
    private var frameCounter = 0
    private var MarkerframeRate = 20 // runs every n frames
    private var NumberofMarkersFound = 0 // Total for a confidence level on the scene
    private var ConfirmationMarkerLevel = 5 // how many times do I need to markers?
    private var tickInitiated = Bool()
    // running session log of objects that are marked as validated in the current scene
    private var ObjectsPlacedDone = [Int]()
    // Object properties
    private var assetMark_0 = 6
    private var assetMark_1 = 6
    private var assetMark_2 = 6
    // Creating a dictionary
    var frame_ids_positions: [Int: marker_seen] = [:]
    var primary_marker = 99
    // Space localisation
    private var visibleSpaceTarget = [SCNVector3]()
    // Activity indicator for the validation process
    @IBOutlet weak var activityWait: UIActivityIndicatorView!
    // Validation class object
    let valid = Validator()
    // holds target tray properties
    let loadedtray = Tray()
    // transform to detected target
    var targTransform = SCNMatrix4()
    
    @IBOutlet var sceneView: ARSCNView!
    
    // Button press used to prevent process overload & button for loading a tray scene
    @IBOutlet var buttonpress: [UIButton]!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var loadmodelbutton: UIButton!
    @IBOutlet weak var ValidateButton: UIButton!
    
    
    //////////////////////////////////////////////////////////
    // main code base
    //////////////////////////////////////////////////////////
    
    // function called on validate request from user
    @IBAction func Validate(_ sender: Any) {
        // if not ready return
        if(isLocalized == false) || (self.activeTasks[self.taskIndex].validation == nil){
            print("Not localised or no validation available for this task")
            return
        }
        
        //self.activityWait.startAnimating()
        self.validateTask(task: &self.activeTasks[self.taskIndex])
        
        if self.valid.AllObjectsValidated(currentTask: self.activeTasks[self.taskIndex]){
            // Check the task as complete
            self.activeTasks[self.taskIndex].complete = true
            self.completeTick.isHidden = false
            self.completeTick.alpha = 1.0
            self.dismiss(animated: true, completion: nil)
            self.nextTask(self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                
                // Fade the tick
                UIView.animate(withDuration: 1.5, delay: 1.5, options: [], animations: {
                    self.completeTick.alpha = 0.0
                }) { (finished: Bool) in
                    self.completeTick.isHidden = true
                    // show the next instruction
                    self.segue()
                }
            })
            
        }
        //self.captureNextFrameForCV = true
        // check whether the ID is present & orientation
        
        
    }
    // function called on back request (unwind segue)
    @IBAction func backToPrevious(_ sender: Any) {
        if let delegate = delegate{
            delegate.updateEvent(activeEvents: activeTasks)
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func nextTask(_ sender: Any) {

        if (taskIndex < activeTasks.count-1) {
            taskIndex = taskIndex + 1
            // Load in current space
            //buttonloadmodel(self)
        }
        
    }
    @IBOutlet weak var Debuggingop: UILabel!
    
    
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    
    @IBAction func pressed(_ sender: Any) {
        //self.reset()
        // to slow down processing only activated on button press
        //self.captureNextFrameForCV = true
        
        //testDatabase()
    }
    
    override func viewDidLoad() {
        
    
        super.viewDidLoad()
        
        self.sceneView.scene.rootNode.addChildNode(getLightNode())
        
        // Hide the completion tick
        self.completeTick.isHidden = true
        self.findMarkerLayer.alpha = 0.0
        self.currentTask = activeTasks[taskIndex]
        Debuggingop.text = "localising"
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        //sceneView.debugOptions = [.showWireframe, .showBoundingBoxes, .showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration and apply debug options
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
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
        
        // This should probably only be called when a plane is detected?
        if (self.frameCounter % self.MarkerframeRate == 0)
        {
                self.findMarkers(frame: frame)
        }
        self.frameCounter = self.frameCounter + 1
    }
    
    
    // Main calling functiondelay: updates pose and id array from passed frame
    func findMarkers(frame: ARFrame) {
        // Current status contains a string as to the tracking status of the world
        let currentstatus = sessionStatus(frame: frame)
            // If ready go ahead and pass
            if (currentstatus == "") {
                let pixelBuffer = frame.capturedImage
                let newframe = OpenCVWrapper.arucodetect(pixelBuffer, withIntrinsics: frame.camera.intrinsics, andMarkerSize: Float64(activeTasks[taskIndex].space.marker_height_m))
                // convert c++ to swift  and place detections in VC hash map
                self.frame_ids_positions = tupleMatrixToDict(tuple: newframe.all_extrinsics, camera: SCNMatrix4.init(frame.camera.transform), last_frame: self.frame_ids_positions, count: Int(newframe.no_markers))
                
                if(self.isLocalized == false){
                    self.segue()
                    self.frame_ids_positions.forEach { id in
                        if isSpaceMarker(id: id.key, current_task: self.currentTask){
                        localiseTray(targTransform: id.value.transform, markerid: Int(id.key))
                        }
                    }
                 
                }else{
                    updateMarkerPositions(rootNode: self.sceneView.scene.rootNode, markers: self.frame_ids_positions, current_task: self.currentTask, primary_m: self.primary_marker)
                    Validate(self)
                }
        // only nodes with names will get called by this function
        return
        }
    }
  
    private func localiseTray(targTransform: SCNMatrix4, markerid: Int) {
        if self.primary_marker == 99 || self.primary_marker == markerid{
            self.primary_marker = markerid
            localizedContentNode.transform = targTransform // apply new transform to node
            localizedContentNode.name = "tray" // prevents updating of position
            
            // add anchor to aid positioning
            let anchor = ARAnchor(transform: simd_float4x4(localizedContentNode.transform))
            sceneView.session.add(anchor:anchor)
            // Calculate the centre of the tray and make child of marker
            let marker = SCNNode()
            let node = SCNNode()
            
            marker.transform = targTransform
            marker.addChildNode(node)
            node.position = loadedtray.CentrePoint(withid: markerid, task: self.currentTask)
            var transform = simd_float4x4(node.worldTransform)
            self.visibleSpaceTarget.append(SCNVector3(transform.columns.3.x,transform.columns.3.y,transform.columns.3.z))
            // does the marker match a trend? This function looks for consecutive estimates
            if (varianceTonorm(vectorEstimates: self.visibleSpaceTarget) < 0.01){
                TrayCentrepoint = loadedtray.TrayCentreNode()
                localizedContentNode.addChildNode(TrayCentrepoint)
                TrayCentrepoint.position = loadedtray.CentrePoint(withid: markerid, task: self.currentTask)
                self.primary_marker = markerid
                sceneView.scene.rootNode.addChildNode(localizedContentNode)
                
                self.dismiss(animated: true, completion: nil)
                self.nextTask(self)
                self.segue()
                
                DispatchQueue.main.async{
                    UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                        self.findMarkerLayer.alpha = 0.0
                        self.markerFound1.alpha = 0.0
                        self.markerFound2.alpha = 0.0
                        self.markerFound3.alpha = 0.0
                        
                    }) { (finished: Bool) in
                        self.findMarkerLayer.isHidden = true
                        self.markerFound1.isHidden = true
                        self.markerFound2.isHidden = true
                        self.markerFound3.isHidden = true
                    }
                }
                self.isLocalized = true
                self.activeTasks[self.taskIndex].complete = true
            }
        }
    }

        func renderer(_ renderer: SCNSceneRenderer,
                               nodeFor anchor: ARAnchor) -> SCNNode?{
            return SCNNode()
        }
    
    func validateTask(task: inout Task){
        var validatedStates = [validationState]()
        // Check validation needs to occur
        if (task.validation == nil) {
            print("No validation requirement attached to task or not yet localised")
            return
        }
        // Check validation for each object in turn
        for object in task.objects {
            // Add the result of each object validation to the array
            validatedStates.append(validateObject(object: object)!)
        }
        // Record the validation state back against the task
        task.validation?.objectStates = validatedStates
        return
    }
    
    // Validates an object relative to the current scene
    func validateObject(object: Object) -> validationState?{
        if let transform = self.frame_ids_positions[Int(object.object_marker.id)]?.transform {
            // now val is not nil and the Optional has been unwrapped, so use it
            
            // remove prevoius instruction for this object
            sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                if (node.name == "instruction" + String(object.object_marker.id) || node.name == "target") {
                    node.removeFromParentNode()
                }
            }
            
            // Create the instructions
            let obj_instruction = InstructionNode()
            // Pass argumentes needed to construct instructions
            obj_instruction.addInstructionsForObject(transform: transform, task: self.currentTask, id: object.object_marker.id, target: TrayCentrepoint.worldTransform, rootNode: self.sceneView.scene.rootNode)

            // Add instructions to the root view
            sceneView.scene.rootNode.addChildNode(obj_instruction)
  
            return obj_instruction.validationstate
        }
        return validationState.not_visible
    }


    
    func reset(){
        // Is there already a localised content node? Destroy it:

        self.NumberofMarkersFound = 0
        self.isLocalized = false
        self.captureNextFrameForCV = false
        
        // validation poperties
        self.ObjectsPlacedDone.removeAll()
    }
    

    
    func RenderNode() -> SCNNode{
        // If there is nothing to render don't
        if activeTasks[taskIndex].objects.count == 0 {
            return SCNNode()
        }
        
        let asset_name = activeTasks[taskIndex].objects.first?.file_name as! String

        var node1 = SCNNode()
        
        // Try to load the node assets from the scene
        if let assetScene = SCNScene(named: activeTasks[taskIndex].objects.first?.parent_scene as! String) {

            
            if let l_node = assetScene.rootNode.childNode(withName: asset_name, recursively: true) {

                let anchor = ARAnchor(transform: simd_float4x4(targTransform))
                sceneView.session.add(anchor:anchor)
                l_node.transform = TrayCentrepoint.transform
                node1 = l_node
                node1.eulerAngles = activeTasks[taskIndex].objects.first?.apply_rotation as! SCNVector3
                
                // scale using object properties
                
                node1.scale = activeTasks[taskIndex].objects.first?.scale as! SCNVector3
                

                // add lighting *todo make this ambient based on lighting sensor
                
                //addLightNodeTo(node1)
            }
            
        }
        return node1
    }
    
    func addLineBetween(start: SCNVector3, end: SCNVector3) -> SCNGeometry {
        let lineGeometry = SCNGeometry.lineFrom(vector: start, toVector: end)
        
        return lineGeometry
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is InstructionViewController
        {
            self.vc = segue.destination as! InstructionViewController
            // pass over all the tasks and the reference to the one selected
            //vc?.delegate = self
            
            self.vc.activeTask = activeTasks[taskIndex]
        }
    }
    
    
    // method to run when table view cell is tapped
    func segue (){
        // Segue to the second view controller after updating
        vc.activeTask = activeTasks[taskIndex]
        vc.update()
        self.performSegue(withIdentifier: "showInstruction", sender: self)
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("shaken")
            //self.dismiss(animated: true, completion: nil)
        }
    }
    
    func TargetMarker()->SCNNode{
        var node = SCNNode(geometry: SCNTorus(ringRadius: 0.2, pipeRadius: 0.001))
        
        let action : SCNAction = SCNAction.rotate(by: 20, around: SCNVector3(0, 0, 1), duration: 3)
        let forever = SCNAction.repeatForever(action)
        node.runAction(forever)
        node.name = "target"
        return node
    }
    
    }

