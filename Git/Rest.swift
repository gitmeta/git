import Foundation

class Rest: NSObject, URLSessionTaskDelegate {
    private var session: URLSession!
    
    override init() {
        super.init()
        session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: OperationQueue())
    }
    
    func urlSession(_: URLSession, task: URLSessionTask, didReceive: URLAuthenticationChallenge, completionHandler: @escaping
        (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, didReceive.previousFailureCount == 0 ? Hub.session.credentials : nil)
    }
    
    func fetch(_ remote: String, error: @escaping((Error) -> Void), result: @escaping((Fetch) throws -> Void)) throws {
        session.dataTask(with: URLRequest(url: try url(remote, suffix: "/info/refs?service=git-upload-pack"), cachePolicy:
            .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)) { [weak self] in
                self?.validate($0, $1, $2, error: error) { try result(Fetch($0)) }
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
        } (try url(remote, suffix: "/git-upload-pack")) as URLRequest) { [weak self] in
            self?.validate($0, $1, $2, error: error) { try result(Pack($0)) }
        }.resume()
    }
    
    func url(_ remote: String, suffix: String) throws -> URL {
        guard !remote.isEmpty, !remote.hasPrefix("http://"), !remote.hasPrefix("https://"), remote.hasSuffix(".git"),
            let remote = remote.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let url = URL(string: "https://" + remote + suffix)
        else { throw Failure.Request.invalid }
        return url
    }
    
    private func validate(_ data: Data?, _ response: URLResponse?, _ fail: Error?,
                          error: @escaping((Error) -> Void), result: @escaping((Data) throws -> Void)) {
        Hub.dispatch.background({
            if let fail = fail {
                throw fail
            } else {
                switch (response as? HTTPURLResponse)?.statusCode {
                case 200, 201:
                    if let data = data, !data.isEmpty {
                        try result(data)
                    } else {
                        throw Failure.Request.empty
                    }
                case 401: throw Failure.Request.auth
                default: throw Failure.Request.response
                }
            }
        }, error: error)
    }
}
