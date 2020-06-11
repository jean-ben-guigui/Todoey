//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
	
	var itemArray = [Item]()
	var selectedCategory: ItemCategory? {
		didSet {
			loadItems()
		}
	}
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	//MARK: - TableView Data Source Methods
	
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
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if (editingStyle == .delete) {
			itemArray.remove(at: indexPath.row)
			saveItems()
			
			tableView.reloadData()
		}
	}
	
	//MARK: - TableView Delegate Methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		itemArray[indexPath.row].done = !itemArray[indexPath.row].done
		saveItems()
		tableView.reloadData()
	}
	
	//MARK: - Add New Items
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		var textfield = UITextField()
		let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
		let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
			if let text = textfield.text {
				let item = Item(context: self.context)
				item.title = text
				item.done = false
				item.parentCategory = self.selectedCategory
				self.itemArray.append(item)
				
				self.saveItems()
			}
		}
		alert.addAction(action)
		alert.addTextField { (alertTextField) in
			textfield = alertTextField
			alertTextField.placeholder = "New item name"
		}
		present(alert, animated: true, completion: nil)
	}
	
	func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
		guard let selectedCategory = selectedCategory, let name = selectedCategory.name else { return }
		do {
			let newPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)
			if let predicate = request.predicate {
				let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, newPredicate])
				request.predicate = compoundPredicate
			} else {
				request.predicate = newPredicate
			}
			
			itemArray = try context.fetch(request)
		} catch {
			print("Error loading data from context \(error)")
		}
		
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
	func saveItems() {
		do {
			try self.context.save()
		} catch {
			print("Error saving context \(error)")
		}
		
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
}

//MARK: - SearchBar Delegate
extension TodoListViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let text = searchBar.text, text.count > 0 {
			let request: NSFetchRequest<Item> = Item.fetchRequest()
			request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", text)
			request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
			
			loadItems(with: request)
		} else {
			loadItems()
		}
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchBar.text?.count == 0 {
			loadItems()
			
			DispatchQueue.main.async {
				searchBar.resignFirstResponder()
			}
		}
	}
}
