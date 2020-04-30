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
   
    
   var itemArray = [Item]() // This is an array of the class Item and storage in memory of our item list
   
    /* Get the default FileManager that provides urls based on directory and domain
       FileManager is a singleton
       We want a path to the document directory for the userDomain home location
     .first is referring to the 1st element of the array (Up to this point you can get the file path)
     Then add .appendingPathComponent to add the path for your plist file
     */
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print(dataFilePath!)
        
        /* Load items stored in the item.plist file into itemArray */
        loadItems()
        
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
        
        saveItems()
        
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
            self.saveItems()
            
        } // end of AlertAction completion closure
        
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
    } // end of addButtonPressed
    
    /* encode our itemArray and write to the item.plist file and reload the table view */
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        }
        catch {
            print("Error encoding itemArray, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems()
    {
        /* Get the contents of url of our path to item.plist file
            Use binding optional to ensure that only uses if have a valid path */
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            /* Pass in the data type of the object [Item] and the file path of where item.plist is located
             to the decoder and read the data into our itemArray */
            do {
               itemArray = try decoder.decode([Item].self, from: data)
            }
            catch {
              print("Error decoding itemArray, \(error)")
            }
        }
    }
    
} // end of class

