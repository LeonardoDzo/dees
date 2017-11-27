//
//  RealManager.swift
//  dees
//
//  Created by Leonardo Durazo on 24/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift
let realm = RealmManager.shared

class RealmManager {
    
    var realm = try! Realm()
    private init(){
       
    }
    static let shared = RealmManager()
    
    /**
     Delete local database
     */
    func deleteDatabase() {
        try! realm.write({
            realm.deleteAll()
        })
    }
    
    /**
     Save array of objects to database
     */
    func saveObjects(objs: [Object]) {
        try! realm.write({
            // If update = true, objects that are already in the Realm will be
            // updated instead of added a new.
            realm.add(objs, update: true)
        })
    }
    func save(objs: Object) {
        do{
            try! realm.write({
                // If update = true, objects that are already in the Realm will be
                // updated instead of added a new.
                realm.add(objs, update: true)
            })
        }
        
        
    }
    
    /**
     Returs an array as Results<object>?
     */
    func getObjects(type: Object.Type) -> Results<Object>? {
        return realm.objects(type)
    }
}

