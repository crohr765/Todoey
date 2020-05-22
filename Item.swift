//
//  Item.swift
//  Todoey
//
//  Created by Cindy Rohr on 5/18/20.
//  Copyright © 2020 Cindy Rohr. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date = Date()
    /* This is the inverse relationship - many to one */
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
