//
//  inventoryItem.swift
//  Formularios
//
//  Created by Adrián Rubio on 4/5/16.
//  Copyright © 2016 Adrián Rubio. All rights reserved.
//

import RealmSwift
import Realm


class InventoryItem: Object {
    dynamic var title = ""
    dynamic var count = 1
}
