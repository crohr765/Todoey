//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Cindy Rohr on 5/26/20.
//  Copyright © 2020 Cindy Rohr. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

   override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
    }
    
    //MARK:  SwipeTableView Datasource Methods
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           /* Define cell as a SwipeTableViewCell -- Identifier should be generic name */
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
    
            /* These cells will use this class for the delegate methods */
            cell.delegate = self
           
            return cell
    }
    
    //MARK: SwipeTableView Delegate Methods
    
        /* Allows to select row and swipe to right to see delete option - then select the delete icon */
        func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
               guard orientation == .right else { return nil }

                let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                     // handle action by updating model with deletion
                    self.updateModel(at: indexPath)
                }

               // customize the action appearance
               deleteAction.image = UIImage(named: "delete-icon")

               return [deleteAction]
           }
    
           /* Allows to swipe across view and remove in one swipe motion */
           func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
               var options = SwipeOptions()
               options.expansionStyle = .destructive
               return options
           }
    
        /* update data model - Each child class should override this and do the actual updating of data model */
        func updateModel(at indexPath : IndexPath) {
         
        }
       
}

    
