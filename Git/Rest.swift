import Foundation

public class Rest: NSObject, URLSessionTaskDelegate, URLSessionDelegate, URLSessionDataDelegate {
    private var session: URLSession!
    
    override init() {
        super.init()
        session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        fatalError("some")
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        fatalError("some")
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
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        fatalError("cuas")
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        fatalError("sas")
    }
    
    public func request() {
        session.dataTask(with: URLRequest(url: URL(string:
            "https://github.com/vauxhall/test.git/info/refs?service=git-upload-pack")!, cachePolicy:
            .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)) { data, response, fail in
                print(data)
                print(String(decoding: data ?? Data(), as: UTF8.self))
                print((response as? HTTPURLResponse)?.statusCode)
//                print(response)
//                print(fail)
        }.resume()
    }
    
    public func post() {
        session.dataTask(with: {
            var request = URLRequest(url: $0, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
            request.httpMethod = "POST"
            request.setValue("application/x-git-upload-pack-request", forHTTPHeaderField: "Content-Type")
            request.httpBody = Data("0032want 0443ec39fd90e514e59a2e5bf81224c0f02de839\n0000".utf8)
            return request
        } (URL(string: "https://github.com/vauxhall/test.git/git-upload-pack")!) as URLRequest) { data, response, fail in
                print(data)
                print(String(decoding: data ?? Data(), as: UTF8.self))
            print((response as? HTTPURLResponse)?.statusCode)
            
            
            
        }.resume()
    }
}
