//
//  File.swift
//  
//
//  Created by ryugel on 24/08/2024.
//  Copyright © 2024 DeRosa. All rights reserved.
//
       

import Fluent

struct CreateAccounts: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("accounts")
            .id()
            .field("email", .string, .required)
            .field("hash_password", .string, .required)
            .unique(on: "email")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("accounts").delete()
    }
}

struct CreateUsers: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("full_name", .string, .required)
            .field("gender", .string)
            .field("biography", .string)
            .field("profile_picture", .string)
            .field("account_id", .uuid, .required, .references("accounts", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}
