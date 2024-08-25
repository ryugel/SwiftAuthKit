import Fluent
import Vapor

func routes(_ app: Application) throws {
    let dontDoThisAtHome = AccountController()
    
    app.get { req async in
        "It works!"
    }
    
    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    app.group("accounts") { accounts in
        accounts.post("register", use: dontDoThisAtHome.createAccounts)
        accounts.get(use: dontDoThisAtHome.getAccounts)
    }
    
    app.group("users") { users in
        users.post("createUser", use: dontDoThisAtHome.createUser)
        users.get(use: dontDoThisAtHome.getUsers)
    }
    
}

