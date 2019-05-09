//
//  UserDataManager.swift
//  crud
//
//  Created by Claudio Sepúlveda Huerta on 5/8/19.
//  Copyright © 2019 csh. All rights reserved.
//

import Foundation
import RealmSwift

//Clase que rescata los objetos usuarios desde la BBDD
final internal class UserDataManager {
    var users : Results<User>?
    
    func loadUsers() -> Results<User> {
        do {
            let realm = try Realm()
            self.users = realm.objects(User.self)
        } catch {
            print("Can't load users")
        }
        return users!
    }
    
    func saveUser(_ name : String) {
        let newUser = User()
        newUser.name = name
        do {
            let realm = try Realm()
            try! realm.write {
                realm.add(newUser)
            }
        } catch {
            print("Can't save user")
        }
    }
    
    func updateUser(_ user : User, newName : String) {
        do {
            let realm = try Realm()
            try! realm.write {
                user.name = newName
            }
        } catch {
            print("Can't update user")
        }
    }
    
    func deleteUser(_ user : User) {
        do {
            let realm = try Realm()
            try! realm.write {
                realm.delete(user)
            }
        } catch {
            print("Can't delete user")
        }
    }
}
