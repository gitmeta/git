import Foundation

class Rest {
    private let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: OperationQueue())
    
    func adv(_ remote: String, error: @escaping((Error) -> Void), result: @escaping((Fetch) -> Void)) throws {
        session.dataTask(with: URLRequest(url: try url(remote, suffix: "/info/refs?service=git-upload-pack"), cachePolicy:
            .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)) {
                if let fail = $2 {
                    error(fail)
                } else if ($1 as? HTTPURLResponse)?.statusCode == 200, let data = $0, !data.isEmpty {
                    do {
                        result(try Fetch(data))
                    } catch let exception {
                        error(exception)
                    }
                } else {
                    error(Failure.Request.empty)
                }
        }.resume()
    }
    
    func pack(_ remote: String, want: String, error: @escaping((Error) -> Void), result: @escaping((Pack) -> Void)) throws {
        session.dataTask(with: {
            var request = URLRequest(url: $0, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 90)
            request.httpMethod = "POST"
            request.setValue("application/x-git-upload-pack-request", forHTTPHeaderField: "Content-Type")
            request.httpBody = Data("""
0032want \(want)
00000009done

""".utf8)
            return request
        } (try url(remote, suffix: "/git-upload-pack")) as URLRequest) {
            if let fail = $2 {
                error(fail)
            } else if ($1 as? HTTPURLResponse)?.statusCode == 200, let data = $0, !data.isEmpty {
                do {
                    result(try Pack(data))
                } catch let exception {
                    error(exception)
                }
            } else {
                error(Failure.Request.empty)
            }
        }.resume()
    }
    
    func url(_ remote: String, suffix: String) throws -> URL {
        guard !remote.isEmpty, !remote.hasPrefix("http://"), !remote.hasPrefix("https://"), remote.hasSuffix(".git"),
            let remote = remote.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let url = URL(string: "https://" + remote + suffix)
        else { throw Failure.Request.invalid }
        return url
    }
}
