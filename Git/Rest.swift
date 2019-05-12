import Foundation

class Rest {
    private let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: OperationQueue())
    
    func fetchAdv(_ remote: String, error: @escaping((Error) -> Void), result: @escaping((Fetch.Adv) -> Void)) {
        guard
            let remote = remote.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: remote + "/info/refs?service=git-upload-pack")
        else { return error(Failure.Request.invalid) }
        session.dataTask(with: URLRequest(url: url, cachePolicy:
            .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)) {
                if let fail = $2 {
                    error(fail)
                } else if ($1 as? HTTPURLResponse)?.statusCode == 200, let data = $0, !data.isEmpty {
                    do {
                        result(try Fetch.Adv(data))
                    } catch let exception {
                        error(exception)
                    }
                }
                error(Failure.Request.empty)
        }.resume()
    }
    
    func request() {
        
    }
    
    public func post() {
        let serial = Serial()
        serial.string("want 0443ec39fd90e514e59a2e5bf81224c0f02de839")
        let serial2 = Serial()
//        serial2.number(UInt32(serial.data.count + 4))
//        serial2.hex("00\(serial.data.count + 4)")
//        serial2.string("00")
//        serial2.hex("50")
//        serial2.string("want 0443ec39fd90e514e59a2e5bf81224c0f02de839\n")
//        serial2.string("0032want 0443ec39fd90e514e59a2e5bf81224c0f02de839\n")
//        serial2.hex("0009done")
        
//        serial2.string("0032want d0713672c2bb4ada8a3da6a633a17086262b78ba\n0032want 0443ec39fd90e514e59a2e5bf81224c0f02de839\n0000")
        
//        serial2.string("003cwant ")
//        serial2.string("d0713672c2bb4ada8a3da6a633a17086262b78ba")
//        serial2.string(" ofs-delta\n")
//        serial2.string("0032want ")
//        serial2.string("d0713672c2bb4ada8a3da6a633a17086262b78ba")
//        serial2.string("\n")
//        serial2.string("0000")
        
        serial2.string("0054want 54cac1e1086e2709a52d7d1727526b14efec3a77 multi_ack side-band-64k ofs-delta\n")
//        serial2.string("0032want d0713672c2bb4ada8a3da6a633a17086262b78ba\n")
        serial2.string("0000")
        serial2.string("0009done\n")
        
        session.dataTask(with: {
            var request = URLRequest(url: $0, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
            request.httpMethod = "POST"
            request.setValue("application/x-git-upload-pack-request", forHTTPHeaderField: "Content-Type")
            request.httpBody = serial2.data
//            request.httpBody = try! JSONSerialization.data(withJSONObject: "0032want 0443ec39fd90e514e59a2e5bf81224c0f02de83800000009done0000")
            return request
        } (URL(string: "https://github.com/vauxhall/test.git/git-upload-pack")!) as URLRequest) { data, response, fail in
                print(data)
                print(String(decoding: data ?? Data(), as: UTF8.self))
            print(response)
            
            print(fail?.localizedDescription)
            
        }.resume()
    }
}
