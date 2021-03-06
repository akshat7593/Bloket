//
//  ViewController.swift
//  ContactsLBTA
//
//  Created by Brian Voong on 11/13/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit
import Contacts
import CoreData
import SQLite
class groupContactsTableViewController: UITableViewController {
    
    var database1: Connection!
    var database2: Connection!
    var favoritableContacts = [FavoritableContact]()
    //var index : Int = 0
   
    let cellId = "cellId123"
    
    //trying to make table of all group names
    var groupNamesTable = Table("GroupNameTable")
    var gColumn = Expression<String>("names")
    var oColumn = Expression<Bool>("onoff")
    
    var tableName = ""

    var grouptable = Table("1")
    var column = Expression<String>("number")
    var nameColumn = Expression<String>("name")
    
    var blockedname = [String]()
    var blockednumbers = [String]()
    //var grouparray = [String]()
    
    
    func makeTable(groupName: String?){
        print("table " + groupName! + " created")
        let groupTable = Table(groupName!)
        grouptable = groupTable

        tableName = groupName!
        
        
        //directory for table
        do {
            
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent(groupName!).appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database1 = database
            print(documentDirectory)
            print("-------")
        } catch {
            print(error)
        }
        //---------
        
        //directory for table
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("GroupNameTable").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database2 = database
        } catch {
            print("abc")
            print(error)
        }
        //---------
        
        let group_table = self.grouptable.create{ (table) in
            table.column(self.column, primaryKey: true)
            table.column(self.nameColumn, primaryKey: false)
        }
        
        do {
            try self.database1.run(group_table)
            print("Created Table")
        } catch {
            print(error)
        }
        
        let insertTableName = self.groupNamesTable.insert(self.gColumn <- tableName,self.oColumn <- false)
        do {
            try self.database2.run(insertTableName)
            print("Table name INSERTED ")
        } catch {
            print(error)
        }

    }
    
    func InsertIntoGroup(cell: UITableViewCell) {
        //        print("Inside of ViewController now...")
        
        // we're going to figure out which name we're clicking on
        
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        
        let contact = twoDimensionalArray[indexPathTapped.section].names[indexPathTapped.row]
        let fname = contact.contact.givenName
        let lname = contact.contact.familyName
        let fullname = fname + " " + lname
        let num = contact.contact.phoneNumbers.first?.value.stringValue ?? ""
        //print(type(of: num))
        
        blockednumbers.append(num)
        blockedname.append(fullname)


        
        //cell.accessoryView?.tintColor = hasFavorited ? UIColor.lightGray : .red
        //print(grouparray)
    }
    
    
    func someMethodIWantToCallRemove(cell: UITableViewCell) {
        //        print("Inside of ViewController now...")
        
        // we're going to figure out which name we're clicking on
        
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        
        let contact = twoDimensionalArray[indexPathTapped.section].names[indexPathTapped.row]
        let fname = contact.contact.givenName
        let lname = contact.contact.familyName
        let fullname = fname + " " + lname
        let num = contact.contact.phoneNumbers.first?.value.stringValue ?? ""
        
        var filterarray = blockednumbers.filter{ $0 != num }
        blockednumbers = filterarray
        
        filterarray = blockedname.filter{ $0 != fullname }
        blockedname = filterarray
        
    
        
        //        tableView.reloadRows(at: [indexPathTapped], with: .fade)
        
        //cell.accessoryView?.tintColor = hasFavorited ? UIColor.lightGray : .red
        //print(grouparray)
    }
    
    var twoDimensionalArray = [ExpandableNames]()
    
    
    
    private func fetchContacts(){
        print("Attempting to fetch Contacts")

        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err=err{
                print("Failed to request access",err)
                return
            }
            
            if granted{
                //print("Access granted")
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                request.sortOrder = CNContactSortOrder.givenName
                do{
                    
                    
                    
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        if(contact.phoneNumbers.first?.value.stringValue ?? "" != ""){
                        self.favoritableContacts.append(FavoritableContact(contact: contact, name: "aks", hasFavorited: false))
                        }
                        
                    })
                    
                    let names = ExpandableNames(isExpanded: true, names: self.favoritableContacts)
                    self.twoDimensionalArray = [names]
                    
                }
                catch let err{
                    print("Failed to enumerate contacts:",err)
                }
                
            }
            else{
                print("Access Denied")
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchContacts()
        
        
        
        navigationItem.title = "Contacts"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(groupContactCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.addTarget(self, action: #selector(addIntoTable), for: .touchUpInside)
        
        button.tag = section
        
        return button
    }
    
    @objc func addIntoTable(button: UIButton) {
        print("Adding numbers into database")
        
        
        //var finArray = [String]()
        print("DONE TAPPED")
        
        //self.loadView()
        
        
        //adding blocked numbers in database
        print(blockednumbers)
        print(blockedname)
        
        //adding blocked numbers in database
        for (index,num) in blockednumbers.enumerated(){
            //print(type(of: num))
            print(index,num)
            print(index,blockedname[index])
            let insertUser = self.grouptable.insert(self.column <- num,self.nameColumn <- blockedname[index])
            do {
                try self.database1.run(insertUser)
                print("INSERTED USER")
            } catch {
                print(error)
            }
            
        }
//        for num in grouparray{
//            //print(type(of: num))
//            let insertUser = self.grouptable.insert(self.column <- num)
//            //print("teste")
//            //print(insertUser)
//            do {
//                try self.database1.run(insertUser)
//                print("INSERTED USER")
//            } catch {
//                print(error)
//            }
//        }
        
        //adding table name to groupNamesTable
        let insertTableName = self.groupNamesTable.insert(self.gColumn <- tableName,self.oColumn <- false)
        do {
            try self.database2.run(insertTableName)
            print("Table name INSERTED ")
        } catch {
            print(error)
        }
        
        //displaying blocked numbers
        do{
            let users = try self.database1.prepare(self.grouptable)
            for user in users {
                print("userNumber: \(user[self.column])")
                print("userName: \(user[self.nameColumn])")
                //finArray.append(user[self.number])
            }
        }
        catch{
            print(error)
        }
        
        //displaying names in tableNames
        do{
            let users = try self.database2.prepare(self.groupNamesTable)
            for user in users {
                print("tableName: \(user[self.gColumn])")
            }
        }
        catch{
            print(error)
        }
        
        print("fetch controller")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return twoDimensionalArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !twoDimensionalArray[section].isExpanded {
            return 0
        }
        
        return twoDimensionalArray[section].names.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactCell
        
        let cell = groupContactCell(style: .subtitle, reuseIdentifier: cellId)
        //cell.temp(cN : favoritableContacts[index].contact.phoneNumbers[0].value.stringValue)
        //index+=1
        //print(index)
        cell.link = self
        let favoritableContact = twoDimensionalArray[indexPath.section].names[indexPath.row]
        //print(favoritableContacts[0].contact.phoneNumbers[0].value.stringValue)
        cell.temp(cN : favoritableContact.contact.phoneNumbers[0].value.stringValue)
        cell.textLabel?.text = favoritableContact.contact.givenName + " " + favoritableContact.contact.familyName
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        cell.detailTextLabel?.text = favoritableContact.contact.phoneNumbers.first?.value.stringValue
        //print("2 new")
        
        //cell.accessoryView?.tintColor = favoritableContact.hasFavorited ? UIColor.red : .lightGray
        
        
        
        //        if showIndexPaths {
        //            //cell.textLabel?.text = "\(favoritableContact.name)   Section:\(indexPath.section) Row:\(indexPath.row)"
        //        }
        
        return cell
    }
    
}








