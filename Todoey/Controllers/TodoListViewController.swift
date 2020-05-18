//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Cindy Rohr on 4/28/20.
//  Copyright © 2020 Cindy Rohr. All rights reserved.
//

import UIKit
import CoreData

/* This app is using the subclass UITableViewController which has a lot
 of built in functionality that has taken care of the delegate & data source set-up */
class TodoListViewController: UITableViewController {
    
    
   var itemArray = [Item]() /* This is an array of the class Item defined in the Data Model and
                                storage in memory of our item list */
    /* Data Model - configured as class definition which auto generates files containing class definition for Item - generates 3 files
        Data (hint use Terminal find cmd to locate these files)
        1. Item+CoreDataClass.swift - defines Item class as NSManagedObject
        2. Item+CoreDataProperties.swift - defines the properties for the Item class and fetchRequest() function to get the properties
        3. DataModel+CoreDataModel.swift - imports necessary libraries */
   
    /* Optional selectedCategory- set by Category View Controller */
    var selectedCategory : Category? {
        /* keyword that will trigger as soon as selectedCategory is
           set to a value */
        didSet {
            loadItems()
        }
    }
    
    /* AppDelegate.persistentContainer.viewContext is the class blueprint to get the data base view.
       UIApplication.shared is a singleton object that will be our live application running and
     this has a delegate so this is used and then down casted to the AppDelegate blueprint */
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /* Get the default FileManager that provides urls based on directory and domain
           FileManager is a singleton
           We want a path to the document directory for the userDomain home location
           for where our CoreData DB is located)
         */
        print (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        /* Load all items from persistent data model */
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
        
        /* remove from scratch memory area for Data Model -
           must be done before removing from itemArray!! */
        // context.delete(itemArray[indexPath.row])
        /* remove from itemArray in memory */
        //itemArray.remove(at: indexPath.row)
        
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
            
            let newItem = Item(context: self.context)// create a new instance of Item class
            newItem.title = textField.text! // update the title
            newItem.done = false            // set to false initially
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)  // Add this new item to our itemArray
            self.saveItems()                // save to database
            
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
    
    /* Takes the current context area for the Data Model and saves to
        presistent Data Model.  Reload the table view with current data */
    func saveItems() {
        
        do {
            try context.save()
        }
        catch {
           print("Error saving context, \(error)")
        }
        
        tableView.reloadData()
    }
    
    /* Request Items from persistent data model and load the itemArray and update tableview for user.
          with - external param used when call this func
          request - internal param used within loadItems
          If no param is passed then use default Item.fetchRequest() which
          will get all items from the database
          predicate is optional to add compound search to category */
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil)
    {
        /* Set-up Category search */
        let categoryPredicate = NSPredicate(format:"parentCategory.name MATCHES %@",selectedCategory!.name!)
        
        /* If optional predicate does contain a value then
           search based on category and passed in search which should be a partial title */
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }
        else { /* search by category only */
            request.predicate = categoryPredicate
        }
        
        do {
            /* Fetches the request from the database and returns results in itemArray */
        itemArray = try context.fetch(request)
        }
        catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
        
    }
    
    
    
} // end of class

//MARK: - search bar methods
extension TodoListViewController : UISearchBarDelegate {
    
    /* triggers once user enters from the search bar */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        /* Set-up a new query - start with requesting all the items from data base */
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        /* set-up search request by title based on what user entered */
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        /* Sort data returned by title in ascending order (ordered in database).
        sortDesciptors expects an array so that is why we have the [] */

        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: request.predicate)
    }
    
    /* Activated when any text changed in the search bar.
       Reload all items in the doto list if no text characters are in search bar */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            /* Dispatch the main application thread */
            DispatchQueue.main.async {
                /* Tell search bar to go into the background now
                   This will remove cursor from searchbar and remove keyboard */
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

