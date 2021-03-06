//
//  CallDirectoryHandler.swift
//  Call_Blocking
//
//  Created by Akshat Agrawal on 09/02/19.
//  Copyright © 2019 Akshat Agrawal. All rights reserved.
//

import Foundation
import CallKit
import SQLite
import CoreData
class CallDirectoryHandler: CXCallDirectoryProvider {
    //var array1 : Array<Any> = []
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        //------------------
        
        
        //print("fetch pressed")
//        do{
//            let users = try self.database.prepare(self.usersTable)
//        }
        
        //-----------------------
        print("check0")
        //print("check0ii")
//        let defaults = UserDefaults.standard
//        //(suiteName: "group.tag.number")
////        array1 = defaults.object(forKey: "block_array") as? [String] ?? [String]()
////        print(array1)
//        let array1 = defaults.object(forKey: "block_array") as? [String] ?? [String]()
//        print(array1)
//        let defaults = UserDefaults(suiteName: "group.tag.number")
//        //(suiteName: "group.tag.number")
//        var array = defaults!.object(forKey: "block_array") as? [String] ?? [String]()
//        array.sort()
//        print(array)
        // Check whether this is an "incremental" data request. If so, only provide the set of phone number blocking
        // and identification entries which have been added or removed since the last time this extension's data was loaded.
        // But the extension must still be prepared to provide the full set of data at any time, so add all blocking
        // and identification phone numbers if the request is not incremental.
        if context.isIncremental {
            print("aa")
            addOrRemoveIncrementalBlockingPhoneNumbers(to: context)

//            addOrRemoveIncrementalIdentificationPhoneNumbers(to: context)
        } else {
            print("bb")
            addAllBlockingPhoneNumbers(to: context)

//            addAllIdentificationPhoneNumbers(to: context)
        }
        print("context0")
        context.completeRequest()
        print("context1")
    }

    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve all phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
        //
        //print(array1)
        // Numbers must be provided in numerically ascending order.
        var finalArray = [Int64]()
        
        let defaults = UserDefaults(suiteName: "group.tag.number")
        //(suiteName: "group.tag.number")
        var array = defaults!.object(forKey: "block_array") as? [String] ?? [String]()
        //array.sort()
        //list of white listed numbers
        let individual_whitelist_array = defaults!.object(forKey: "individual_whitelist_array") as? [String] ?? [String]()
        //ends
        
        //Converting array to Set
        var WhiteNumberSet = Set<Int64>()
        for num in individual_whitelist_array{
            var newString = num.components(separatedBy:CharacterSet.decimalDigits.inverted).joined(separator: "")
            if(newString[newString.startIndex]=="0"){
                newString.remove(at: newString.startIndex)
            }
            if(newString.count==10){
                newString="91"+newString
            }
            if(newString.count==12){
                WhiteNumberSet.insert(Int64(newString)!)
            }
            
        }
        
        
        print("array sorted according to name")
        print(array)
        print(array.count)
        var temp : Array<Int64> = []
        for item in array {
            var newString = item.components(separatedBy:CharacterSet.decimalDigits.inverted).joined(separator: "")
            if(newString[newString.startIndex]=="0"){
                newString.remove(at: newString.startIndex)
            }
            if(newString.count==10){
                newString="91"+newString
            }
            if(newString.count==12){
                temp.append(Int64(newString)!)
            }
        }
        temp.sort()
        print("array sorted according to number")
        //print(temp)
        let flag = defaults!.object(forKey: "flag_individual_black") as? Int16
        if(flag! == 2){
            WhiteNumberSet.removeAll()
        }
        var previous = Int64(0)
        for num in temp{
            if(num>previous && !WhiteNumberSet.contains(num)){
                finalArray.append(num)
                previous = num
            }
        }
        
        print(temp.count)
            let allPhoneNumbers: [CXCallDirectoryPhoneNumber] = finalArray
        for phoneNumber in allPhoneNumbers {
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
        }
        print("check1")
    }

    private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve any changes to the set of phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
        //918460663919
        
        //removing old value from the call directory extension
        var finalArray = [Int64]()
        
        let defaults = UserDefaults(suiteName: "group.tag.number")
        //(suiteName: "group.tag.number")
//starts.......................
        //var array = defaults!.object(forKey: "block_array_old") as? [String] ?? [String]()
        //array.sort()
        //print(array)
//        var temp : Array<Int64> = []
//        for item in array {
//            let newString = item.components(separatedBy:CharacterSet.decimalDigits.inverted).joined(separator: "")
//            temp.append(Int64(newString)!)
//        }
//        print("Remove---------------------")
//        print(temp)
//ends.......................
//        let phoneNumbersToRemove: [CXCallDirectoryPhoneNumber] = temp
//        for phoneNumber in phoneNumbersToRemove {
//            context.removeBlockingEntry(withPhoneNumber: phoneNumber)
//        }
        context.removeAllBlockingEntries()
        //Adding new Numbers
        var array = defaults!.object(forKey: "block_array") as? [String] ?? [String]()
        //array.sort()
        //list of white listed numbers
        let individual_whitelist_array = defaults!.object(forKey: "individual_whitelist_array") as? [String] ?? [String]()
        //ends
        
        //array to set
        var WhiteNumberSet = Set<Int64>()
        for num in individual_whitelist_array{
            var newString = num.components(separatedBy:CharacterSet.decimalDigits.inverted).joined(separator: "")
            if(newString[newString.startIndex]=="0"){
                newString.remove(at: newString.startIndex)
            }
            if(newString.count==10){
                newString="91"+newString
            }
            if(newString.count==12){
                WhiteNumberSet.insert(Int64(newString)!)
            }
            
        }
        print("--test WhitenumberSet -- ")
        print(WhiteNumberSet)
        //var flag = Int16(-1)
        let flag = (defaults!.object(forKey: "flag_individual_black") as? Int16)!
        print("value of flag for black or white")
        print(flag)
        if(flag == 2){
            WhiteNumberSet.removeAll()
        }
        var temp : Array<Int64> = []
        for item in array {
            var newString = item.components(separatedBy:CharacterSet.decimalDigits.inverted).joined(separator: "")
            if(newString[newString.startIndex]=="0"){
                newString.remove(at: newString.startIndex)
            }
            if(newString.count==10){
                newString="91"+newString
            }
            if(newString.count==12){
                temp.append(Int64(newString)!)
            }
        }
        temp.sort()
        //print(temp)
        var previous = Int64(0)
        for num in temp{
            if(num>previous && !WhiteNumberSet.contains(num)){
                finalArray.append(num)
                previous = num
            }
        }
        print(finalArray.count)
        print("add----------------------------")
        
        let phoneNumbersToAdd: [CXCallDirectoryPhoneNumber] = finalArray
        for phoneNumber in phoneNumbersToAdd {
            print(phoneNumber)
            print("\n")
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
        }

//       context.addBlockingEntry(withNextSequentialPhoneNumber: 9199)
//        print("check2")

        // Record the most-recently loaded set of blocking entries in data store for the next incremental load...
    }

//    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
//        // Retrieve phone numbers to identify and their identification labels from data store. For optimal performance and memory usage when there are many phone numbers,
//        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
//        //
//        // Numbers must be provided in numerically ascending order.
//        let allPhoneNumbers: [CXCallDirectoryPhoneNumber] = [ +918460663919 ]
//        let labels = [ "Telemarketer", "Local business" ]
//
//        for (phoneNumber, label) in zip(allPhoneNumbers, labels) {
//            context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: label)
//        }
//        print("check3")
//    }

//    private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
//        // Retrieve any changes to the set of phone numbers to identify (and their identification labels) from data store. For optimal performance and memory usage when there are many phone numbers,
//        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
//        let phoneNumbersToAdd: [CXCallDirectoryPhoneNumber] = [ +918460663919 ]
//        let labelsToAdd = [ "New local business" ]
//
//        for (phoneNumber, label) in zip(phoneNumbersToAdd, labelsToAdd) {
//            context.addIdentificationEntry(withNextSequentialPhoneNumber: phoneNumber, label: label)
//        }
//
//        let phoneNumbersToRemove: [CXCallDirectoryPhoneNumber] = [ +918460663919 ]
//
//        for phoneNumber in phoneNumbersToRemove {
//            context.removeIdentificationEntry(withPhoneNumber: phoneNumber)
//        }
//        print("check4")
//        // Record the most-recently loaded set of identification entries in data store for the next incremental load...
//    }
    
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    //print("check5")
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
       // print("check6")
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occured while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
