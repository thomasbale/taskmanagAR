//
//  TaskTableViewController.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 15/03/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import UIKit

class InstructionViewController: UITableViewController, DisplayViewControllerDelegate {
    
    
    
    var TapSegueIdentifier = "showARView"
    var activeEvent = Event()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        let imageName = "tick_ios.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.view.addSubview(imageView)
        //Imageview on Top of View
        self.view.bringSubviewToFront(imageView)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return activeEvent.tasks.count
    }
    
    
 
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let index = (self.tableView.indexPathForSelectedRow)!
        if segue.destination is ARViewController
        {
            let vc = segue.destination as? ARViewController
            // pass over all the tasks and the reference to the one selected
            vc?.delegate = self
            vc?.activeTasks = activeEvent.tasks
            vc?.taskIndex = index.row
        }
    }
    
    
    // method to run when table view cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.secondViewController.activeEvent = events[indexPath.row]
        // Segue to the second view controller
        self.performSegue(withIdentifier: TapSegueIdentifier, sender: self)
    }
    
    // delegate function to pass updated array of tasks back to contoller
    func updateEvent(activeEvents: [Task]){
        activeEvent.tasks = activeEvents
        self.tableView.reloadData()
    }
    

    
    
    
}
