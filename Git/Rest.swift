import Foundation

public class Rest: NSObject, URLSessionTaskDelegate {
    private var session: URLSession!
    
    override init() {
        super.init()
        session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        fatalError("redirect")
    }
    
    public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        fatalError("waiting")
    }
    
    @available(OSX 10.13, *)
    @available(iOS 11.0, *)
    public func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        fatalError("delay")
    }
    
    
    
    public func request() {
        session.dataTask(with: URLRequest(url: URL(string:
            "https://github.com/vauxhall/worldcities.git/info/refs?service=git-upload-pack")!, cachePolicy:
            .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)) { data, response, fail in
                print(data)
                print(response)
                print(fail)
        }.resume()
    }
    
    public func post() {
        let task = session.dataTask(with: {
            var request = URLRequest(url: $0, cachePolicy:.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 50)
            request.httpMethod = "POST"
            request.setValue("application/x-git-upload-pack", forHTTPHeaderField: "Content-Type")
            request.httpBody = Data("""
0032want 2b5aca053bd33a9ccab5a7ddbf53cb68ae1ce767
0000
""".utf8)
            return request
        } (URL(string: "https://github.com/vauxhall/worldcities.git/git-upload-pack")!) as URLRequest) { data, response, fail in
                print(data)
                print(String(decoding: data ?? Data(), as: UTF8.self))
                print(response)
                print(fail)
        }
        task.resume()
    }
}
