//
//  LocalDataCoreDataClass.swift
//  movietime
//
//  Created by Harvinder Laliya on 30/04/23.
//

import Foundation
import CoreData

class LocalDataCoreDataClass: ObservableObject {
    let container = NSPersistentContainer(name: "LocalDataModel")
    
    init () {
        container.loadPersistentStores{ desc, error in
            if let error = error {
                print("Cant loaad required data \(error.localizedDescription)")
            }
            
        }
    }
    
    //Save user context
    func save (context: NSManagedObjectContext) {
        do{
            try context.save()
            print("Data was saved!")
        } catch {
            print("Data was not saved!!")
        }
    }
    
    //EDIT AND ADD local user data
    func addData(uid: String, loginStatus: String, context: NSManagedObjectContext){
        let localData = LocalData(context: context)
        localData.uid = uid
        localData.loginStatus = loginStatus
        save(context: context)
    }
    
    func editData(localData: LocalData,uid: String,loginStatus: String,context: NSManagedObjectContext) {
        localData.uid = uid
        localData.loginStatus = loginStatus
        save(context: context)
    }
    
    
}
