//
//  TaskTableViewController.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 15/03/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import UIKit

class TaskTableViewController: UITableViewController {

    var TapSegueIdentifier = "showARView"
    var activeEvent = Event()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        }
        
            cell!.textLabel?.text = activeEvent.tasks[indexPath.row].name
            cell!.detailTextLabel?.text = activeEvent.tasks[indexPath.row].description
        
        cell!.backgroundColor = UIColor.green
        // check for incomplete tasks
        if activeEvent.tasks[indexPath.row].complete != true{
            cell!.backgroundColor = UIColor.red
        }
        
        return cell!
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
         if segue.destination is ARMarkerViewController
         {
         let vc = segue.destination as? ARMarkerViewController
            // pass over the specific task for action
         let selection = activeEvent.tasks[index.row]
         vc?.activeTask = selection
         }
    }
    
    
    // method to run when table view cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.secondViewController.activeEvent = events[indexPath.row]
        // Segue to the second view controller
        self.performSegue(withIdentifier: TapSegueIdentifier, sender: self)
    }

}
