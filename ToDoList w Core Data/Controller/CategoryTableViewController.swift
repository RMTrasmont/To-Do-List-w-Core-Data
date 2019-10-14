//
//  CategoryTableViewController.swift
//  ToDoList w Core Data
//
//  Created by Rafael M. Trasmontero on 9/27/19.
//  Copyright © 2019 RMT. All rights reserved.
//

import UIKit
import CoreData
class CategoryTableViewController: UITableViewController {
    
    var categoriesArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoriesArray[indexPath.row].name
        return cell
    }
   
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Segue to this categories Items screen// SETUP "Prepare for segue" First
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListTableViewController
        //get Indexpath of the selected cell to set the "Selected category" for the Next Screen
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            destinationVC.parentCategory = categoriesArray[selectedIndexPath.row]
        }
        
    }
    
    //MARK: - SWIPE TO DELETE METHODS
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            //*** DELETE FROM CONTEXT FIRST, THEN CELL , THEN SAVE CHANGES
            context.delete(categoriesArray[indexPath.row])
            self.categoriesArray.remove(at: indexPath.row)
            saveCategories()
        }
    }
    
    //MARK: - Adding New Category via Alert & TextField
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //Local reference
        var localTextField = UITextField()
        //Alert Popup
        let alert = UIAlertController.init(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Add Category", style: .default) { (action) in
            //*** CREATE CORE DATA ITEM & FILL IN ALL ATTRIBUTES OF THE ENTITY
            let newCategory = Category(context: self.context)
            newCategory.name = localTextField.text!
            self.categoriesArray.append(newCategory)
            self.saveCategories()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter New Item"
            localTextField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: SAVE AND LOAD TO & FROM CORE DATA
    
    func saveCategories(){
        do{
            try context.save()
        } catch {
            print("ERROR SAVING CONTEXT: \(error.localizedDescription) ")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do{
            categoriesArray = try context.fetch(request)
        } catch {
            print("ERROR LOADING ITEMS\(error.localizedDescription):")
        }
        tableView.reloadData()
    }

}


