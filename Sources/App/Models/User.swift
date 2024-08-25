//
//  File.swift
//
//
//  Created by ryugel on 24/08/2024.
//  Copyright © 2024 DeRosa. All rights reserved.
//


import Fluent
import Vapor


final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "full_name")
    var fullName: String
    
    @Field(key: "gender")
    var gender: String?
    
    @Field(key: "biography")
    var biography: String?
    
    @Field(key: "profile_picture")
    var profilePicture: String?
    
    @Parent(key: "account_id")
    var account: Account
    
    init() {}
    
    init(id: UUID? = nil, fullName: String, gender: String? = nil, biography: String? = nil, profilePicture: String? = nil, accountID: UUID) {
        self.id = id
        self.fullName = fullName
        self.gender = gender
        self.biography = biography
        self.profilePicture = profilePicture
        self.$account.id = accountID
    }
    
    static func validateName(_ name: String) throws -> Void {
        guard !name.isEmpty else {
            throw Abort(.badRequest, reason: "Name cannot be empty")
        }
    }
    
    static func validateUserUnique(accountID: UUID, on database: Database) -> EventLoopFuture<Bool> {
        return User.query(on: database)
            .filter(\.$account.$id == accountID)
            .count()
            .map { count in
                return count > 0
            }
    }
}
