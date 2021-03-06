//
//  DisplayBlockedNumbers.swift
//  temp2
//
//  Created by Akshat Agrawal on 09/04/19.
//  Copyright © 2019 Akshat Agrawal. All rights reserved.
//

import UIKit
import Contacts
import CoreData
import SQLite

class DisplayBlockedNumbers: UITableViewController {
    
    var database: Connection!
    var favoritableContacts = [FavoritableContacts]()
    var twoDimensionalArray = [BlockedExpandableNames]()
    let usersTable = Table("blocknumbers")
    let number = Expression<String>("number")
    let name = Expression<String>("name")
    
    let cellId = "cellId123123"
    let b_logic = Block_logic()
    var blacklistData:[blacklistModal] = []
    //var blockednumbers = [String]()
    //var blockedname = [String]()
    
    //let contact_list = contactsTableViewController()
    var contact_number = [String]()
    func delete(cell: UITableViewCell) {
        
        print("delete tapped")
        // we're going to figure out which name we're clicking on
        
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }

        let contact = twoDimensionalArray[indexPathTapped.section].name[indexPathTapped.row]
        let num = contact.number
        
        
        let user = self.usersTable.filter(self.number == num!)
        let deleteUser = user.delete()
        do {
            try self.database.run(deleteUser)
        } catch {
            print(error)
        }

        self.tableView.reloadData()
        self.viewDidLoad()
        b_logic.black_white()
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blacklistData.removeAll()
        
        print("inside viewdidload")
        print(contactsTableViewController().number_contact)
        do {
            print("first")
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("blocknumbers").appendingPathExtension("sqlite3")
            print(fileUrl)
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        
        do {
            self.favoritableContacts.removeAll()
            let users = try self.database.prepare(self.usersTable)
            for user in users {
                let fullname = user[self.name]
                let num = user[self.number]
                
                self.favoritableContacts.append(FavoritableContacts(name: fullname,number: num, hasFavorited: false))
                
            }
            
            let names = BlockedExpandableNames(isExpanded: true, name: self.favoritableContacts)
            self.twoDimensionalArray = [names]

            
        } catch {
            print(error)
        }

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //navigationItem.title = "Contacts"
        
        //navigationController?.navigationBar.prefersLargeTitles = true
        
//        let contact_list = contactsTableViewController()
//        contact_number = contact_list.number_contact
//        print(contact_number)
        
//        let defaults = UserDefaults(suiteName: "group.tag.number")
//        let array = defaults!.object(forKey: "all_number") as? [String] ?? [String]()
//        print(array)
        
        tableView.register(BlockedContactCell.self, forCellReuseIdentifier: cellId)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        self.viewDidLoad()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "EnableCustomHeaderBlack") as! EnableCustomHeaderBlack
        headerCell.backgroundColor = UIColor.gray
        headerCell.link = self
        headerCell.check()
        return headerCell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return twoDimensionalArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if !twoDimensionalArray[section].isExpanded {
            self.viewDidLoad()
            return 0
        }
        self.viewDidLoad()
        return twoDimensionalArray[section].name.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactCell
        
        let cell = BlockedContactCell(style: .subtitle, reuseIdentifier: cellId)
        
        cell.link = self
        
        let favoritableContact = twoDimensionalArray[indexPath.section].name[indexPath.row]
        
        cell.textLabel?.text = favoritableContact.name
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cell.detailTextLabel?.text = favoritableContact.number
        cell.accessoryView?.tintColor = favoritableContact.hasFavorited ? UIColor.red : .lightGray
        
        
        return cell
    }

}
