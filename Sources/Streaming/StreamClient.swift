import Foundation
import AsyncHTTPClient
import NIOCore
import ArgumentParser
import MyParser
import Logging

let logger = Logger(label: "com.example.Streaming")

enum HTTPClientError: Error {
    case invalidResponse(String)
}

@main
struct Streaming: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "streaming",
        abstract: "A command-line tool for parsing data from HTTP stream."
    )

    @Argument(help: "The path of a specs CSV file to parse.")
    var specs: String

    @Argument(help: "The stream URL to fetch the data from.")
    var url: String

    @Argument(help: "The output file.")
    var outputPath: String

    func fetchStream(url: String, outputURL: URL, dataParser: DataParser) async throws {
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        defer {
            try? httpClient.syncShutdown()
        }
        var request = HTTPClientRequest(url: url)
        request.method = .GET

        let response = try await httpClient.execute(request, timeout: .seconds(30))

        guard response.status == .ok else {
            throw HTTPClientError.invalidResponse("Invalid response status: \(response.status)")
        }

        logger.info("Fetching data from \(url), passing to \(outputURL.path)")
        for try await byteBuffer in response.body {
            if let string = byteBuffer.getString(at: 0, length: byteBuffer.readableBytes) {
                if let output = try await dataParser.parseData(string) as? String {
                    if let data = output.data(using: .utf8) {
                        let fileHandle = try FileHandle(forWritingTo: outputURL)
                        defer {
                            fileHandle.closeFile()
                        }
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                    }
                }
            }
        }
    }

    func run() async throws {
        do {
            let csv = try String(contentsOf: URL(fileURLWithPath: specs))
            let dataParser = try await DataParser(parseSpecs(csv))
            let outputURL = URL(fileURLWithPath: "\(outputPath)")
            if !FileManager.default.fileExists(atPath: outputURL.path) {
                FileManager.default.createFile(atPath: outputURL.path, contents: nil, attributes: nil)
            }
            try await fetchStream(url: url, outputURL: outputURL, dataParser: dataParser)
        } catch {
            logger.error("Error: \(error.localizedDescription)")
        }
    }
}
