//
//  Item.swift
//  Todoey
//
//  Created by Arthur Duver on 09/06/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct Item: Codable {
	var title: String = ""
	var done: Bool = false
}
