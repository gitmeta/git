import Foundation

public class Rest {
    private var session = URLSession(configuration: .ephemeral)
    
    public func request() {
        session.dataTask(with: URLRequest(url: URL(string:
            "https://github.com/vauxhall/test.git/info/refs?service=git-upload-pack")!, cachePolicy:
            .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)) { data, response, fail in
                print(data)
                debugPrint(String(decoding: data ?? Data(), as: UTF8.self))
                print((response as? HTTPURLResponse)?.statusCode)
//                print(response)
//                print(fail)
        }.resume()
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
        
        serial2.string("0054want d0713672c2bb4ada8a3da6a633a17086262b78ba multi_ack side-band-64k ofs-delta\n")
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
