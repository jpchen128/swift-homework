import Vapor
import MyParser
 
let app = try Application(.detect())
defer { app.shutdown() }

let csv = try String(contentsOf: URL(fileURLWithPath: "./specs.csv"))
let dataParser = try await DataParser(parseSpecs(csv))

app.http.server.configuration.hostname = "0.0.0.0"
app.http.server.configuration.port = 80

app.get() { req -> String in
    return "Use POST method to send data"
}

app.post() { req -> String in
    guard let bodyString = req.body.string else {
        throw Abort(.badRequest)
    }
    req.logger.info("Received request: \(bodyString)")
    guard let data = try await dataParser.parseData(bodyString) as? String else {
        throw Abort(.badRequest)
    }
    req.logger.info("Parsed data: \(data)")
    return data
}

try await app.execute()