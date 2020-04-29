//
//  ViewController.swift
//  Todoey
//
//  Created by Cindy Rohr on 4/28/20.
//  Copyright © 2020 Cindy Rohr. All rights reserved.
//

import UIKit

/* This app is using the subclass UITableViewController which has a lot
 of built in functionality that has taken care of the delegate & data source set-up */
class TodoListViewController: UITableViewController {
    let itemArray = ["FindMike", "Buy Eggs","Destroy Demogoron"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK - Tableview Datasource Methods
    
    /* Declare numberOfRowsInSection here:
     This is called automatically before rendering the table view and
     returns how many rows we will have in our view */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    /* Declare cellForRowAtIndexPath here:
       This is called automatically to render the data for each cell,
       indexPath is the current row index that tableView is asking for and
       then we return the cell with the data to be presented */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* This function retrieves the protype cell object on the storyboard
            for a specific row or index */
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        /* This sets the textLabel of the cell object to the desired data contents */
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* Stop highlighting what was just selected */
        tableView.deselectRow(at: indexPath, animated: true)
        /* This sets or deselects the checkmark for the cell selected */
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
    }

}

