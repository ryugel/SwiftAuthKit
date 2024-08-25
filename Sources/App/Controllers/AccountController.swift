//
//  File.swift
//  
//
//  Created by ryugel on 25/08/2024.
//  Copyright © 2024 DeRosa. All rights reserved.
//
       

import Fluent
import Vapor

struct AccountController {
    @Sendable
    func createAccounts(req: Request) throws -> EventLoopFuture<Account> {
        let account = try req.content.decode(Account.self)
        
        try Account.validateEmail(account.email)
        
        return Account.emailAlreadyExists(account.email, on: req.db).flatMap { exists in
            guard !exists else {
                return req.eventLoop.makeFailedFuture(Abort(.conflict, reason: "Email already taken"))
            }
            
            do {
                try account.validateAndHashPassword(password: account.hashPassword)
                return account.save(on: req.db).map { account }
            } catch let error as AbortError {
                return req.eventLoop.makeFailedFuture(error)
            } catch {
                return req.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "Unexpected error occurred"))
            }
        }
    }
    
    @Sendable
    func getAccounts(req: Request) -> EventLoopFuture<[Account]> {
        return Account.query(on: req.db).with(\.$user).all()
    }
    
    @Sendable
    func createUser(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        try User.validateName(user.fullName)
        
        return Account.find(user.$account.id, on: req.db).unwrap(or: Abort(.notFound, reason: "Account not found")).flatMap { account in
            return User.query(on: req.db)
                .filter(\.$account.$id == user.$account.id)
                .count()
                .flatMap { count in
                    guard count == 0 else {
                        return req.eventLoop.future(error: Abort(.badRequest, reason: "An user already exists for this account"))
                    }
                    
                    return user.save(on: req.db).flatMap {
                        User.query(on: req.db)
                            .filter(\.$id == user.id ?? UUID())
                            .first()
                            .unwrap(or: Abort(.notFound))
                    }
                }
        }
    }
    
    @Sendable
    func getUsers(req: Request) -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }
}
