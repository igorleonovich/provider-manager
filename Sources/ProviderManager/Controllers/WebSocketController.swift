import Foundation
import WebSocket

final class WebSocketController {
    
    weak var core: Core?
    var managerID: String
    var webSocket: WebSocket!
    
    init(core: Core, managerID: String) {
        self.core = core
        self.managerID = managerID
    }
    
    func start(_ completion: @escaping (Error?) -> Void) {
            
        do {
            print("\(Date()) [ws] connecting")
            webSocket = try HTTPClient.webSocket(hostname: Constants.host,
                                                 port: Constants.wsPort,
                path: "/connectManager/\(managerID)",
                on: MultiThreadedEventLoopGroup.init(numberOfThreads: 1)).do { webSocket in
                    print("\(Date()) [ws] connected")
            }.catch { error in
                print(error)
            }.wait()
            
            webSocket.onText { webSocket, text in
//                print("\(Date()) [ws] [text from server] \(text)")
                if text == "managerID OK" {
                print("\(Date()) [ws] [managerID OK]")
                    completion(nil)
                } else if text == "managerID FAIL" {
                    print("\(Date()) [ws] [managerID FAIL]")
                    completion(Error.managerIDNotFoundOnServer)
                }
            }
            
            webSocket.onBinary { webSocket, data in
                print("\(Date()) [ws] [data from server] \(data)")
            }
            
            _ = self.webSocket.onClose.map {
               print("\(Date()) [ws] [closed]")
            }
            
        } catch {
            print(error)
        }
    }
}

extension WebSocketController {
    enum Error: Swift.Error {
        case managerIDNotFoundOnServer
    }
}
