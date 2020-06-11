//
//  CategoryController.swift
//  Todoey
//
//  Created by Arthur Duver on 11/06/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryController: UITableViewController {
	
	var categoryArray = [ItemCategory]()
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	override func viewDidLoad() {
        super.viewDidLoad()
		loadCategories()
    }
	
	//MARK: - TableView Datasource Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categoryArray.count
    }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryItemCellIdentifier) {
			cell.textLabel?.text = categoryArray[indexPath.row].name
			return cell
		}
		fatalError("cannot dequeue cell for category table view")
	}
	
	//MARK: - Data Manipulation Methods
	func loadCategories(with request: NSFetchRequest<ItemCategory> = ItemCategory.fetchRequest()) {
		do {
			categoryArray = try context.fetch(request)
		} catch {
			print("Error loading data from context \(error)")
		}
		
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
	func saveCategories() {
		do {
			try self.context.save()
		} catch {
			print("Error saving context \(error)")
		}
		
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
	//MARK: - Add new categories
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		var addCategoryTextField: UITextField?
		let alert = UIAlertController(title: "Add category", message: "", preferredStyle: .alert)
		alert.addTextField { (textField) in
			addCategoryTextField = textField
			textField.placeholder = "New category name"
		}
		let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
			if let name = addCategoryTextField?.text {
				let newCategory = ItemCategory(context: self.context)
				newCategory.name = name
				self.categoryArray.append(newCategory)
				self.saveCategories()
			}
		}
		
		alert.addAction(action)
		present(alert, animated: true)
	}
	
	
	//MARK: - TableView Delegate Methods
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: K.Segue.goToItems, sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destinationVC = segue.destination as? TodoListViewController, let indexPath = tableView.indexPathForSelectedRow {
			destinationVC.selectedCategory = categoryArray[indexPath.row]
		}
	}

}
