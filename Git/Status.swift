import Foundation

public struct Status {
    public internal(set) var untracked = [URL]()
    public internal(set) var added = [URL]()
    public internal(set) var modified = [URL]()
    public internal(set) var deleted = [URL]()
}
