//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Cindy Rohr on 5/10/20.
//  Copyright © 2020 Cindy Rohr. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
   var categories = [Category]() /* This is an array of the class Item */
    
    /* AppDelegate.persistentContainer.viewContext is the class blueprint to get the data base view.
       UIApplication.shared is a singleton object that will be our live application running and
     this has a delegate so this is used and then down casted to the AppDelegate blueprint
     
    The context will be used to create, read, update and destroy data to the data base */
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        print (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadCategories()
    }
    
    //MARK: - TableView Datasource Methods
    /* Declare numberOfRowsInSection here:
     This is called automatically before rendering the table view and
     returns how many rows we will have in our view */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
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
        
         /* This sets the textLabel of the cell object to the desired data contents */
         cell.textLabel?.text = categories[indexPath.row].name
 
         return cell
     }
    
    //MARK: - Data Manipulation Methods
    /* Takes the current context area for the Data Model and saves to
    presistent Data Model.  Reload the table view with current data */
    func saveCategory() {
        do {
          try context.save()
        }
        catch {
            print("Error saving Category \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
        categories = try context.fetch(request)
        }
        catch {
          print("Error loading Categories \(error)")
        }
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
            let newcategory = Category(context: self.context)
            /* update the instance with name entered by user */
            newcategory.name = textField.text!
            /* Add to categories array */
            self.categories.append(newcategory)
            /* Save in data base and update tableview for user */
            self.saveCategory()
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
        /* Get the current index path of the category selected by user -- this is an optional so make sure that the row has been selected -- pull the category name from array and
            update the selectedCategory in the TodoListViewController */
        if let indexpath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexpath.row]
        }
    }
        
    
}
