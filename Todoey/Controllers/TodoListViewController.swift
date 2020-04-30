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
    let defaults = UserDefaults.standard // Define user defaults
    
   var itemArray = [Item]() // This is an array of the class Item and storage in memory of our item list
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /* Test if have any defaults set-up for our TotoList and if so update
           the persistent defaults into memory */
        let newItem = Item() // Create a new instance of class item
        newItem.title = "Find Mike"
        itemArray.append(newItem)
        let newItem2 = Item() // Create a new instance of class item
        newItem2.title = "Buy Eggs"
        itemArray.append(newItem2)
        let newItem3 = Item() // Create a new instance of class item
        newItem3.title = "Destroy Demogorgon"
        itemArray.append(newItem3)
        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            itemArray = items
        }
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
       then we return the cell with the data to be presented.
       This also is call when calling reloadData */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* This function retrieves the protype cell object on the storyboard
            for a specific row or index */
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        /* This sets the textLabel of the cell object to the desired data contents */
        cell.textLabel?.text = item.title
        /* This sets the current state of the done checkmark for our view */
        cell.accessoryType = item.done  == true ? .checkmark : .none
   
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    /* activated when user selects a specific row */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* Update state of done to the opposite in itemArray */
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        /* reload the tableview to reflect the change */
        tableView.reloadData()
        
        /* Stop highlighting what was just selected */
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() // Need to define here to expand the scope
        
        /* Create alert controller with title and style */
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        /* define button action to be created at bottom of alert box */
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            /* What will happen once the user has clicked Add new item in our UIAlert */
            /* append the new entered item to the array */
            let newItem = Item() // create a new instance of Item class
            newItem.title = textField.text! // update the title, default of done will be set to false
            self.itemArray.append(newItem)  // Add this new item to our itemArray
            
            /* save new item in persistent user defaults */
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            /* must reload the table with the new data */
            self.tableView.reloadData()
            
        }
        
        /* Defines a textfield within the alert controller -
           This is where the user enters a new todo item */
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            /* save reference to alertTextField */
            textField = alertTextField
        }
        
        /* attaches an action to your alert controller */
        alert.addAction(action)
        
        /* presents the alert */
        present(alert, animated: true, completion: nil)
    }
}

