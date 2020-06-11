//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
	
	var itemArray = [Item]()
	
	let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
		loadItems()
    }
	
	// MARK: - TableView Data Source Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		itemArray.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.todoItemCellIdentifier, for: indexPath)
		let item = itemArray[indexPath.row]
		cell.textLabel?.text = item.title
		cell.accessoryType = item.done ? .checkmark : .none
		return cell
	}
	
	//MARK: - TableView Delegate Methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		itemArray[indexPath.row].done = !itemArray[indexPath.row].done
		tableView.reloadData()
		saveItems()
	}
	
	//MARK: - Add New Items
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		var textfield = UITextField()
		
		let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
		
		let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
			if let text = textfield.text {
				var item = Item()
				item.title = text
				self.itemArray.append(item)
				
				self.saveItems()
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		}
		alert.addAction(action)
		alert.addTextField { (alertTextField) in
			textfield = alertTextField
			alertTextField.placeholder = "Create new item"
		}
		present(alert, animated: true, completion: nil)
	}
	
	func loadItems() {
		let decoder = PropertyListDecoder()
		
		if let filePath = dataFilePath {
			do {
				let data = try Data.init(contentsOf: filePath)
				itemArray = try decoder.decode([Item].self, from: data)
			} catch {
				print("Error decoding : \(error)")
			}
		}
	}
	
	func saveItems() {
		let encoder = PropertyListEncoder()
		do {
			let data = try encoder.encode(self.itemArray)
			if let filePath = self.dataFilePath {
				try data.write(to: filePath)
			}
		} catch {
			print("Error encoding item array")
		}
	}
}

