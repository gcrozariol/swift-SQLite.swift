//
//  ViewController.swift
//  Sequel Lite
//
//  Created by Guilherme Crozariol on 7/16/17.
//  Copyright © 2017 Guilherme Crozariol. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {
    
    @IBOutlet weak var resultView: UITextView!
    
    // Database
    var database: Connection!
    
    // Table
    
    let usersTable = Table("users")
    
    // Columns
    let id = Expression<Int>("id")
    let name = Expression<String>("name")
    let email = Expression<String>("email")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            
            // File's directory
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            // Setting file name and its extension
            let fileUrl = documentDirectory.appendingPathComponent("users").appendingPathExtension("sqlite3")
            
            // Connect to the database
            let database = try Connection(fileUrl.path)
            
            // Set this connection to be globally seen
            self.database = database
            
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func createTable() {
        
        // Setting the columns into the table
        let createTable = self.usersTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name)
            table.column(self.email, unique: true)
        }
        
        // Creating the table set above
        do {
            try self.database.run(createTable)
            print("Table created.")
        } catch {
            print(error)
        }
    }
    
    @IBAction func insertUser() {
        
        let alert = UIAlertController(title: "Insert User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = "Name" }
        alert.addTextField { (tf) in tf.placeholder = "Email" }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let name = alert.textFields?.first?.text,
                let email = alert.textFields?.last?.text
                else { return }
            print(name)
            print(email)
            
            // Set the users' values into the respective columns
            let insertUser = self.usersTable.insert(self.name <- name, self.email <- email)
            
            // Insert the columns' values into the table
            do {
                try self.database.run(insertUser)
                self.resultView.text = "User inserted! Please, list users to bring the updated list."
            } catch {
                print(error)
            }
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func listUsers() {
        
        // Bring information from the database
        do {
            self.resultView.text = ""
            let users = try self.database.prepare(self.usersTable)
            
            for user in users {
                
                self.resultView.text! += """
                User Id: \(user[self.id])
                Name: \(user[self.name])
                Email: \(user[self.email])
                
                
                """
            }
            
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func updateUser() {
        
        let alert = UIAlertController(title: "Update User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = "User ID" }
        alert.addTextField { (tf) in tf.placeholder = "Email" }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let userIdString = alert.textFields?.first?.text,
                let userId = Int(userIdString),
                let email = alert.textFields?.last?.text
            else { return }
            
            let user = self.usersTable.filter(self.id == userId)
            let updateUserEmail = user.update(self.email <- email)
            
            do {
                self.resultView.text = "User updated! Please, list users to bring the updated list."
                try self.database.run(updateUserEmail)
            } catch {
                print(error)
            }
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteUser() {
        
        let alert = UIAlertController(title: "Update User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = "User ID" }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let userIdString = alert.textFields?.first?.text,
            let userId = Int(userIdString)
            else { return }
            
            let user = self.usersTable.filter(self.id == userId)
            let delete = user.delete()
            
            do {
                self.resultView.text = "User deleted! Please, list users to bring the updated list."
                try self.database.run(delete)
            } catch {
                print(error)
            }
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

