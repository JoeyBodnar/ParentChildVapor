//
//  Pet.swift
//  ParentChildTutorial
//
//  Created by Stephen Bodnar on 26/08/2017.
//
//

import Vapor
import FluentProvider
import HTTP

extension Pet {
    var owner: Parent<Pet, User> {
         return parent(id: userId)
    }
}

final class Pet: Model {
    let storage = Storage()
    var name: String
    var userId: Identifier
    
    static let idKey = "id"
    static let nameKey = "name"
    static let userIdKey = "user_id"
    
    init(name: String, userId: Identifier) {
        self.name = name
        self.userId = userId
    }
    
    init(row: Row) throws {
        name = try row.get(Pet.nameKey)
        userId = try row.get(Pet.userIdKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Pet.nameKey, name)
        try row.set(Pet.userIdKey, userId)
        return row
    }
}


extension Pet: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Pet.nameKey)
            builder.foreignId(for: User.self)
        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Pet: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(Pet.nameKey),
            userId: json.get(Pet.userIdKey)
        )
    }
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Pet.idKey, id)
        try json.set(Pet.nameKey, name)
        try json.set(Pet.userIdKey, userId)
        return json
    }
}
