//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Cindy Rohr on 5/10/20.
//  Copyright © 2020 Cindy Rohr. All rights reserved.
//

//import Foundation
import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    /* try! is acceptable when using Realm
       Initialize a new data point to Realm */
   let realm = try! Realm()
    
    var categories : Results<Category>?  /* Results object is returned when query Realm and it will contain Category objects */

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        print (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        let currentdate = Date()
        print("Date:",currentdate)
        loadCategories()
    }
    
    //MARK: - TableView Datasource Methods
    /* Declare numberOfRowsInSection here:
     This is called automatically before rendering the table view and
     returns how many rows we will have in our view */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /* if categories is not nil then return count otherwise
           if it is nil return 1 (Nil Coalescing Operator) */
        return categories?.count ?? 1
    }
    /* Declare cellForRowAtIndexPath here:
        This is called automatically to render the data for each cell,
        indexPath is the current row index that tableView is asking for and
        then we return the cell with the data to be presented.
        This also is called when executing reloadData */
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         /* This function retrieves the protype cell object on the storyboard
             for a specific row or index */
         let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
         /* This sets the textLabel of the cell object to the desired data contents as long as categories is not nil otherwise return No categories added message. */
         cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
 
         return cell
     }
    
    //MARK: - Data Manipulation Methods
    /* Takes the current context area for the Data Model and saves to
    presistent Data Model.  Reload the table view with current data */
    func save(category : Category) {
        do {
            try realm.write {
                realm.add(category) /* add category class object to data base */
            }
        }
        catch {
            print("Error saving Category \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    /* Fetch current categories from Realm DB and update our categories in memory.
       Reload the view for the user */
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField() // Need to define here to expand the scope
        
        /* Create alert controller with title and style */
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        /* Define button to be defined at bottom of alert box
           with handler when alert action is completed by user */
        let action = UIAlertAction(title: "Add Category", style: .default)
        { (action) in
            /* create a new instance of category class */
            let newcategory = Category()
            /* update the instance with name entered by user */
            newcategory.name = textField.text!
        
            /* Save in data base and update tableview for user */
            self.save(category: newcategory)
        } // end of AlertAction completion closure
        
        /* Defines a textfield within the alert controller -
           This is where the user enters a new category */
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            /* save reference to alertTextField */
            textField = alertTextField
        }
        /* attaches an action to your alert controller */
        alert.addAction(action)
        
        /* present the alert to the user */
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: - TableView Delegate Methods
    
    /* user has selected specific category */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* Segue to Items view */
        performSegue(withIdentifier: "goToItems", sender: self)
    
    }
    
    /* Just before segue to Items view */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /* set-up pointer to ToDoListViewController */
        let destinationVC = segue.destination as! TodoListViewController
        /* Get the current index path of the category selected by user -- this is an optional and will only update the selectedCategory if it is not nil -- pull the category name from array and
            update the selectedCategory in the TodoListViewController */
        if let indexpath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexpath.row]
        }
    }
        
    
}
