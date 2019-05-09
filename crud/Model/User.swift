//
//  User.swift
//  crud
//
//  Created by Claudio Sepúlveda Huerta on 5/8/19.
//  Copyright © 2019 csh. All rights reserved.
//

import Foundation
import RealmSwift

// Clase Usuario, la cual con objetos llenará la lista
class User: Object {
    @objc dynamic var name = ""
}
