import Vapor
import MyParser
 
let app = try Application(.detect())
defer { app.shutdown() }

let csv = try String(contentsOf: URL(fileURLWithPath: "./specs.csv"))
let dataParser = try await DataParser(parseSpecs(csv))

app.post("parse") { req -> String in
    guard let bodyString = req.body.string else {
        throw Abort(.badRequest)
    }
    return try await dataParser.parseData(bodyString) as? String ?? ""
}

try await app.execute()