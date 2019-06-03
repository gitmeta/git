import Foundation

class Rest {
    private let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: OperationQueue())
    
    func fetch(_ remote: String, error: @escaping((Error) -> Void), result: @escaping((Fetch) throws -> Void)) throws {
        session.dataTask(with: URLRequest(url: try url(remote, suffix: "/info/refs?service=git-upload-pack"), cachePolicy:
            .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)) { data, response, fail in
                Hub.dispatch.background({
                    if let fail = fail {
                        throw fail
                    } else if (response as? HTTPURLResponse)?.statusCode == 200, let data = data, !data.isEmpty {
                        try result(Fetch(data))
                    } else {
                        throw Failure.Request.empty
                    }
                }, error: error)
        }.resume()
    }
    
    func pack(_ remote: String, want: String, have: String = "", error: @escaping((Error) -> Void), result: @escaping((Pack) throws -> Void)) throws {
        session.dataTask(with: {
            var request = URLRequest(url: $0, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 90)
            request.httpMethod = "POST"
            request.setValue("application/x-git-upload-pack-request", forHTTPHeaderField: "Content-Type")
            request.httpBody = Data("""
0032want \(want)
00000009done

""".utf8)
            return request
        } (try url(remote, suffix: "/git-upload-pack")) as URLRequest) { data, response, fail in
            Hub.dispatch.background({
                if let fail = fail {
                    throw fail
                } else if (response as? HTTPURLResponse)?.statusCode == 200, let data = data, !data.isEmpty {
                    try result(Pack(data))
                } else {
                    throw Failure.Request.empty
                }
            }, error: error)
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
