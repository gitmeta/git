import Foundation

public struct Failure: LocalizedError {
    public struct Repository {
        public static let duplicating = Failure("This is already a repository.")
        public static let invalid = Failure("This is not a repository.")
    }
    
    public struct Index {
        public static let malformed = Failure("Unable to read index.")
    }
    
    public struct Press {
        public static let unreadable = Failure("Unable to read compressed file.")
    }
    
    public struct Tree {
        public static let unreadable = Failure("Unable to read tree.")
    }
    
    public struct Commit {
        public static let unreadable = Failure("Unable to read commit.")
        public static let empty = Failure("Nothing to commit.")
        public static let credentials = Failure("Username and Email need to be configured.")
        public static let message = Failure("Commit message can't be empty.")
        public static let ignored = Failure("Attemping to commit ignored file.")
    }
    
    public struct Add {
        public static let double = Failure("File has already been added.")
        public static let not = Failure("File does not exists.")
        public static let outside = Failure("File is not in project's directory.")
    }
    
    public struct User {
        public static let name = Failure("Invalid name.")
        public static let email = Failure("Invalid email.")
    }
    
    public var errorDescription: String? { return "Error: " + string }
    private let string: String
    private init(_ string: String) { self.string = string }
}
