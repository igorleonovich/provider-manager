import Foundation
import SPMUtility

struct DeployCommand: Command {
    
    let command = "deploy"
    let overview = "Deploying config"
    var subparser: ArgumentParser
    var options: Options?
    
    private let config: PositionalArgument<String>
    
    init(parser: ArgumentParser) {
        subparser = parser.add(subparser: command, overview: overview)
        config = subparser.add(positional: "config", kind: String.self, usage: "JSON config to deploy")
    }
    
    func run(with arguments: ArgumentParser.Result) throws {
        guard let config = arguments.get(config) else {
            return
        }
        try deploy(config)
    }
    
    private func deploy(_ config: String) throws {
        
        do {
            let deploymentConfigData = try Data(contentsOf: URL(fileURLWithPath: config))
            let managerToServerAction = ManagerToServerAction(type: ManagerToServerActionType.deployConfig.rawValue,
                                                          data: deploymentConfigData)
            let managerToServerActionData = try JSONEncoder().encode(managerToServerAction)
            let core = Core()
            core.setup()
            core.connect { error in
                if let error = error {
                    print(error)
                } else {
                    core.webSocketController.webSocket.send(managerToServerActionData)
                }
            }
            
//            guard let url = URL(string: "\(Constants.baseURL)/deployments") else { return }
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.httpBody = data
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//                if let error = error {
//                    print(error)
//                } else {
//                    print("[server] deployment started")
//                }
//            }
//            task.resume()
        } catch {
            throw Error.cantReadConfigFromJSONFile
        }
    }
}

extension DeployCommand {
    enum Error: Swift.Error {
        case cantReadConfigFromJSONFile
    }
}
