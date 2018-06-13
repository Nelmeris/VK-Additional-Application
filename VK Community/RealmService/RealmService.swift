//
//  RealmService.swift
//  VK Community
//
//  Created by Артем on 17.05.2018.
//  Copyright © 2018 Nelmeris. All rights reserved.
//

import RealmSwift

class RealmService {
    
    static func resaveData<Type: RealmModel>(_ data: [Type]) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.delete(realm.objects(Type.self))
            realm.add(data)
            try realm.commitWrite()
        } catch let error {
            print(error)
        }
    }
    
    static func updateData<Type: RealmModel>(_ data: [Type]) {
        do {
            let realm = try Realm()
            
            realm.beginWrite()
            
            var delete = realm.objects(Type.self)
            for item in data {
                delete = delete.filter("id != %@", item.value(forKey: "id") as! Int)
            }
            realm.delete(delete)
            
            var data = data
            for (index, item) in data.enumerated() {
                for item2 in realm.objects(Type.self) {
                    if item.isEqual(item2) {
                        data.remove(at: data.index(of: item)!)
                        break
                    }
                }
            }
            
            realm.add(data, update: true)
            try realm.commitWrite()
        } catch let error {
            print(error)
        }
    }
    
    static func loadData<Type: RealmModel>() -> Results<Type>? {
        do {
            let realm = try Realm()
            return realm.objects(Type.self)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    static func clearDataBase() {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.deleteAll()
            try realm.commitWrite()
        } catch let error {
            print(error)
        }
    }
    
    static func clearData<Type: RealmModel>(_ data: [Type]) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.delete(realm.objects(Type.self))
            try realm.commitWrite()
        } catch let error {
            print(error)
        }
    }
    
    static func deleteData<Type: RealmModel>(_ data: [Type]) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.delete(data)
            try realm.commitWrite()
        } catch let error {
            print(error)
        }
    }
    
    static func getFileURL() -> URL? {
        do {
            let realm = try Realm()
            return realm.configuration.fileURL
        } catch let error {
            print(error)
            return nil
        }
    }
    
}
