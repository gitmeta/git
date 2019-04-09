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
    }
    
    public var errorDescription: String? { return "Error: " + string }
    private let string: String
    private init(_ string: String) { self.string = string }
}
