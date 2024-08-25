//
//  File.swift
//
//
//  Created by ryugel on 24/08/2024.
//  Copyright © 2024 DeRosa. All rights reserved.
//


import Fluent
import Vapor

final class Account: Model, Content {
    static let schema = "accounts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "hash_password")
    var hashPassword: String
    
    @OptionalChild(for: \.$account)
    var user: User?
    
    init() {}
    
    init(id: UUID? = nil, email: String, hashPassword: String) {
        self.id = id
        self.email = email
        self.hashPassword = hashPassword
    }
    
    func validateAndHashPassword(password: String) throws -> Void {
        guard !password.isEmpty else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }
        
        guard password.count >= 8 else {
            throw Abort(.badRequest, reason: "Password must be at least 8 characters long")
        }
        
        guard password.rangeOfCharacter(from: .uppercaseLetters) != nil else {
            throw Abort(.badRequest, reason: "Password must contain at least one uppercase letter")
        }
        
        guard password.rangeOfCharacter(from: .lowercaseLetters) != nil else {
            throw Abort(.badRequest, reason: "Password must contain at least one lowercase letter")
        }
        
        guard password.rangeOfCharacter(from: .decimalDigits) != nil else {
            throw Abort(.badRequest, reason: "Password must contain at least one digit")
        }
        
        guard password.rangeOfCharacter(from: .symbols) != nil else {
            throw Abort(.badRequest, reason: "Password must contain at least one special character")
        }
        
        do {
            self.hashPassword = try Bcrypt.hash(password)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to hash password")
        }
    }
    
    static func validateEmail(_ email: String) throws -> Void {
        let emailRegex = "^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard predicate.evaluate(with: email) else {
            throw Abort(.badRequest, reason: "Invalid email format")
        }
    }
    
    static func emailAlreadyExists(_ email: String, on database: Database) -> EventLoopFuture<Bool> {
        return Account.query(on: database)
            .filter(\.$email == email)
            .count()
            .map { count in
                return count > 0
            }
    }
}
