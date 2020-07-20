//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Cindy Rohr on 4/28/20.
//  Copyright © 2020 Cindy Rohr. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

/* This app is using the subclass SwipeTableViewController */
class TodoListViewController: SwipeTableViewController {
    /* Default colors for nav bar */
    let BLUE_COLOR = "1D9BF6"
    let WHITE_COLOR = "F5F5F5"
    
    /* Establish an instance of Realm */
    let realm = try! Realm()
    /* Tried to color the outline of the searchBar like lesson showed but didn't work */
    @IBOutlet weak var searchBar: UISearchBar!
    
    /* Results object is returned when query Realm and it will contain Item objects */
    var todoItems : Results<Item>?
     
   
    /* Optional selectedCategory- set by Category View Controller */
    var selectedCategory : Category? {
        /* keyword that will trigger as soon as selectedCategory is
           set to a value */
        didSet {
           loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /* Get the default FileManager that provides urls based on directory and domain
           FileManager is a singleton
           We want a path to the document directory for the userDomain home location
           for where our CoreData DB is located)
         */
        //print (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        /* Load all items from persistent data model */
        loadItems()
        
        tableView.separatorStyle = .none
        
    }
    
    /* This will trigger just before User sees the view */
    override func viewWillAppear(_ animated: Bool) {
        
        /* update title object with currently selected category name */
        title = selectedCategory?.name
        
        /* Get selected category cell color */
        guard let colorHexString = selectedCategory?.cellColor else { fatalError("No Cell Color available")}
        /* Get complementary color of selected color */
        let complementColor = UIColor.init(complementaryFlatColorOf: UIColor(hexString: colorHexString))!
        
        updateNavBar(withHexCode: colorHexString, hexCode: UIColor.hexValue(complementColor)())
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        /* Set Nav Bar back to original coloring */
        updateNavBar(withHexCode: BLUE_COLOR, hexCode: WHITE_COLOR)
    }
    
    //MARK - Nav Bar Code set-up Methods
    
    /* colorHexString    - color to set the nav bar
       objColorHexString - color to set the objects and title within nav bar */
    func updateNavBar(withHexCode colorHexString : String, hexCode objColorHexString : String ) {
        
       guard let navBar = navigationController?.navigationBar else { fatalError("Navigational Controller does not exist")}
        
       if let colorHexCode = UIColor(hexString: colorHexString) {
          /* Tints the color of the nav bar at top using desired color */
          navBar.barTintColor = colorHexCode
       }
       else {
          /* Tint nav bar to default color*/
          navBar.barTintColor = UIColor(hexString: BLUE_COLOR)
       }
       
       if let objColorHexCode = UIColor(hexString:  objColorHexString){
          /* set interactive elements within nav bar to desired color */
          navBar.tintColor = objColorHexCode
          /* set title name in middle of navBar to desired color */
          navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : objColorHexCode]
       }
       else {
          let WhiteColorUItype = UIColor(hexString: WHITE_COLOR)
          /* set interactive elements within nav bar to default color */
          navBar.tintColor = WhiteColorUItype
          /* set title name in middle of navBar to default */
          navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : WhiteColorUItype!]
       }

    }
    
    //MARK - Tableview Datasource Methods
    
    /* Declare numberOfRowsInSection here:
     This is called automatically before rendering the table view and
     returns how many rows we will have in our view */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    /* Declare cellForRowAtIndexPath here:
       This is called automatically to render the data for each cell,
       indexPath is the current row index that tableView is asking for and
       then we return the cell with the data to be presented.
       This also is call when calling reloadData */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* This function retrieves the protype cell object on the storyboard
            for a specific row or index -- calls super class SwipeTableViewController */
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        /* Make sure we have a item that is not nil */
        if let item = todoItems?[indexPath.row] {
            /* This sets the textLabel of the cell object to the desired data contents */
            cell.textLabel?.text = item.title
            /* This sets the current state of the done checkmark for our view */
            cell.accessoryType = item.done  == true ? .checkmark : .none
            
            /* Start with category color */
            /* Get a gradiant of this color based on percentage of total number of items
               Force unwrap the selected category cell color and if it is not nil then darken
               will be called */
            if let color = UIColor.init(hexString: selectedCategory!.cellColor)?.darken(byPercentage: CGFloat(CGFloat(indexPath.row) / CGFloat(todoItems!.count))){
                  cell.backgroundColor = color
                  /* Make sure that the text contrast is correct for the color */
                  cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: color, isFlat: true)
            }
        }
    
        else {
            cell.textLabel?.text = "No Items Added"
        }
        
   
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    /* activated when user selects a specific row */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* if user selected item is not nil then reverse the done flag in memory and
           then write to Realm db */
        if let item = todoItems?[indexPath.row] {
            do {
               try realm.write {
                 item.done = !item.done
               }
            }
            catch {
                print("Error Setting Done \(error)")
            }
        }
        
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
           /* if currently selected category is not nil then
              create a new Item class instance and update with the new title.
              Then append this to the memory of the Realm database and
              save to the database */
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let newItem = Item()                   // create a new instance of Item class
                        newItem.title = textField.text!        // update the title
                        currentCategory.items.append(newItem)  // append item to memory for db
                   }
                }
                catch {
                    print("Error Saving Item \(error)")
                }
            }
            self.tableView.reloadData()
            
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
    
    /* Update todoItems with items from the selectedCategory passed from Category View Controller
       and sorted in ascending order.
       Refresh tableview for user to see */
    func loadItems()
    {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
   
        tableView.reloadData()
    }
    
    /* Delete Item when swipe */
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            }
            catch {
              print("Error Deleting Item \(error)")
            }
        }
    }
    
    
} // end of class

//MARK: - search bar methods
extension TodoListViewController : UISearchBarDelegate {
    
    /* triggers once user enters from the search bar */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        /* update todoItems with a filtered view by title containing what user entered and sort
           by title in ascending order */
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
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

