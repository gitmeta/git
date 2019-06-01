import Foundation

public struct Failure: LocalizedError {
    public struct Repository {
        public static let duplicating = Failure("This is already a repository.")
        public static let invalid = Failure("This is not a repository.")
    }
    
    public struct Parsing {
        public static let malformed = Failure("Unable to read file.")
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
        public static let not = Failure("File does not exists.")
        public static let outside = Failure("File is not in project's directory.")
    }
    
    public struct User {
        public static let name = Failure("Invalid name.")
        public static let email = Failure("Invalid email.")
    }
    
    public struct Pack {
        public static let indexNotFound = Failure("Index file for pack not found.")
        public static let packNotFound = Failure("Pack file not found.")
        public static let invalidIndex = Failure("Index file for pack malformed.")
        public static let invalidPack = Failure("Pack file malformed.")
        public static let invalidDelta = Failure("Pack delta malformed.")
        public static let object = Failure("Unreadable pack object.")
        public static let size = Failure("Size not match.")
        public static let read = Failure("Can't read packed data.")
        public static let adler = Failure("Decompression checksum failed.")
    }
    
    public struct Fetch {
        public static let advertisement = Failure("Invalid advertisement.")
        public static let empty = Failure("No references in advertisement.")
    }
    
    public struct Request {
        public static let invalid = Failure("Invalid URL.")
        public static let empty = Failure("Empty response from server.")
    }
    
    public struct Clone {
        public static let already = Failure("There is already a repository in this directory.")
        public static let name = Failure("Failed to create a directory with that repository name.")
        public static let directory = Failure("A directory already exists with the name of the repository.")
        public static let unpack = Failure("Clone failed while unpacking.")
    }
    
    public var errorDescription: String? { return string }
    private let string: String
    private init(_ string: String) { self.string = string }
}
