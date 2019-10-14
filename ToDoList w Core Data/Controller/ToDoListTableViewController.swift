//
//  ViewController.swift
//  ToDoList w Core Data
//
//  Created by Rafael M. Trasmontero on 9/24/19.
//  Copyright © 2019 RMT. All rights reserved.
//

import UIKit
//***IMPORT CORE DATA
import CoreData

class TodoListTableViewController: UITableViewController {
    
    var itemsArray = [Item]()
    var parentCategory:Category? {
    //Use property Observers to quickly load Category items once the Category cell is selected on prior screen
        didSet{
            loadItems()
        }
    }
    
    //*** CREATE VARIABLE TO ACCESS THE SINGLETON CONTEXT (WHERE WE SAVE CORE DATA)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //*** SEE WHERE THE CURRENT DATA IS BEING SAVED
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    
    //MARK: - Tableview Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemsArray[indexPath.row]
        cell.textLabel?.text = item.title
        // VALUE = CHECK CONDITION ? USE IF TRUE : USE IF FALSE
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
        
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Toggle True/False
        itemsArray[indexPath.row].done = !itemsArray[indexPath.row].done
        
        saveItems()
        
        //De-Highlights selection
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Adding New Items via Alert & TextField
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //Local reference
        var localTextField = UITextField()
        
        //Alert Popup
        let alert = UIAlertController.init(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Add Item", style: .default) { (action) in
            //*** CREATE CORE DATA ITEM & FILL IN ALL ATTRIBUTES OF THE ENTITY
            let newItem = Item(context: self.context)
            newItem.title = localTextField.text!
            newItem.done = false
            newItem.itemCategory = self.parentCategory
            self.itemsArray.append(newItem)
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter New Item"
            localTextField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    
    }
    
    //MARK: - SWIPE TO DELETE METHODS
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            //*** DELETE FROM CONTEXT FIRST, THEN CELL , THEN SAVE CHANGES
            context.delete(itemsArray[indexPath.row])
            self.itemsArray.remove(at: indexPath.row)
            saveItems()
        }
    }
    
    //*** SAVE OUR ITEM OBJECT TO CORE DTATA BY CALLING CONTEXT.SAVE
    func saveItems(){
        
        do{
            try context.save()
        } catch {
            print("ERROR SAVING CONTEXT: \(error.localizedDescription) ")
        }
        tableView.reloadData()
    }
    
//    *** LOAD ITEMS FROM CORE DATA AND SET IT INTO OUR ITEMS ARRAY

//    func loadItems(){
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        do{
//            itemsArray = try context.fetch(request)
//        } catch {
//            print("ERROR LOADING ITEMS\(error.localizedDescription):")
//        }
//        tableView.reloadData()
//    }
    
//    *** LOAD ITEMS FILTERED WITH PARENT CATEGORY WE CLICKED FROM CORE DATA
//    *** PROVIDING DEFAULT PARAMETER ALLOWS THE LOADING OF FILTERED ITEMS(NSPREDICATES) OR ALL ITEMS (ITEM.FETCHREQUEST)
//    *** defaultRequest Loads All Items related the category
//    *** searchPredicate filters the items by word match
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest(),with searchPredicate: NSPredicate? = nil) {
        
        //Filter via Category predicate (Default show all Category related items)
        let categoryPredicate = NSPredicate(format: "itemCategory.name MATCHES %@", parentCategory!.name!)
        
        //If a additional Search Predicate exist, make the request either a simple request or a combined/compounded one
        if let additionalPredicate = searchPredicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[categoryPredicate , additionalPredicate])
        } else {
            request.predicate = categoryPredicate
            }
        
        
        do{
            itemsArray = try context.fetch(request)
        } catch {
            print("ERROR LOADING ITEMS\(error.localizedDescription):")
        }
        tableView.reloadData()
    }
}

//MARK: Search bar Delegate Methods

extension TodoListTableViewController: UISearchBarDelegate {
    
    //FETCHING ITEMS THAT ARE FILTERED BY OUR SEARCH
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Query request from core data
        let myrequest: NSFetchRequest<Item> = Item.fetchRequest()
        //Use nspredicate to filter the search (See Predicate Cheat Sheet @ Realm.io, use [cd] for case insensitive)
        let mypredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
    
        //Sort returning value by title in ascending order
            let mySortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            myrequest.sortDescriptors = [mySortDescriptor]
            //Load filtered items into local array
            loadItems(with: myrequest, with: mypredicate)
        }
    
    //LOAD ALL ITEMS AGAIN WHEN WE EXIT SEARCH
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            //Dismiss Keyboard Imediately by going to main thread
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
        

}



