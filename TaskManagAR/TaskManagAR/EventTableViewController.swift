//
//  EventTableViewController.swift
//  TaskManagAR
//
//  Created by Thomas Bale on 13/03/2019.
//  Copyright © 2019 Thomas Bale. All rights reserved.
//

import UIKit
import CoreData

/*
 This VC establishes the database connection and passes events into the AR view
 
*/


class EventTableViewController: UITableViewController {
    // Database initialisation
    var container: NSPersistentContainer!
    
    let TapSegueIdentifier = "showEventViewController"
    var secondViewController = TaskTableViewController()
    
    // for testing the location ID is specified in the source
    
    let events:[Event] = getEventsForLocation(locationID: 123)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check database is connected
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        runDatabase()
        // The persistent container is now available.

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
        return events.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        }
        
        print("\(#function) --- section = \(indexPath.section), row = \(indexPath.row)")
        
        cell!.textLabel?.text = events[indexPath.row].name
        cell!.detailTextLabel?.text = events[indexPath.row].description
        
        cell!.backgroundColor = UIColor.green
        // if there are any incomplete events go red
        for status in events[indexPath.row].tasks {
            if status.complete != true{
                cell!.backgroundColor = UIColor.red
            }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // get a reference to the second view controller

        let index = (self.tableView.indexPathForSelectedRow)!
        if segue.destination is TaskTableViewController
        {
            let vc = segue.destination as? TaskTableViewController
            let selection = events[index.row]
            vc?.activeEvent = selection
        }
        
        //secondViewController.activeEvent =
        
        // set a variable in the second view controller with the data to pass
    }

    
    // method to run when table view cell is tapped
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.secondViewController.activeEvent = events[indexPath.row]
        // Segue to the second view controller
        self.performSegue(withIdentifier: TapSegueIdentifier, sender: self)
    }
}


///


