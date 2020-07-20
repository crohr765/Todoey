//
//  Category.swift
//  Todoey
//
//  Created by Cindy Rohr on 5/18/20.
//  Copyright © 2020 Cindy Rohr. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var cellColor : String = ""
    /* items is reference to List of Item objects -- List is specific to Realm This defines the forward one to many relationship */
    let items = List<Item>()
}
