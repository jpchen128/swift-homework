import Foundation
import ArgumentParser
import MyParser
import Logging

let logger = Logger(label: "com.example.Homework")

enum MainError: Error {
    case runtimeError(String)
}

@main
struct Homework: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "homework",
        abstract: "A command-line tool for parsing specific specs and data."
    )

    @Option(name: .shortAndLong, help: "The path of specs CSV files to parse.")
    var specs: String?

    @Option(name: .shortAndLong, help: "The path of data files to parse.")
    var data: String?

    @Option(name: .shortAndLong, help: "The output directory.")
    var output: String?

    func run() async throws {
        var formatDataParserDict: [String: DataParser] = [:]
        do {
            try await parseSpecsFiles(&formatDataParserDict, specsPath: specs ?? "specs")

            let outputPath = output ?? "output"
            if !FileManager.default.fileExists(atPath: outputPath) {
                try FileManager.default.createDirectory(atPath: outputPath,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            try await parseDataFiles(formatDataParserDict, dataPath: data ?? "data", outputPath: outputPath)
        } catch {
            logger.error("Error: \(error.localizedDescription)")
        }
    }

    // Parse specs files and store DataParser objects in a dictionary, keyed by specs name
    // Works concurrently for each file, same for the data files parsing
    func parseSpecsFiles(_ formatDataParserDict: inout [String: DataParser],
                         specsPath: String) async throws {
        let enumerator = FileManager.default.enumerator(
                                            at: URL(fileURLWithPath: specsPath),
                                            includingPropertiesForKeys: [.isRegularFileKey],
                                            options: [.skipsHiddenFiles])!
        var tasks: [String: Task<[Spec], Error>] = [:]
        for case let url as URL in enumerator {
            let specsName = url.deletingPathExtension().lastPathComponent
            tasks[specsName] = Task {
                let csv = try String(contentsOfFile: url.path)
                return try await parseSpecs(csv)
            }
        }
        for (specsName, task) in tasks {
            do {
                let specs = try await task.value
                formatDataParserDict[specsName] = DataParser(specs)
                logger.info("Parsed specs: \(specsName)")
            } catch {
                logger.error("Error while parsing specs '\(specsName)': \(error.localizedDescription)")
            }
        }
    }

    // Parse data files and write the parsed data to output files
    func parseDataFiles(_ formatDataParserDict: [String: DataParser],
                        dataPath: String, outputPath: String) async throws {
        let enumerator = FileManager.default.enumerator(
                                                at: URL(fileURLWithPath: dataPath),
                                                includingPropertiesForKeys: [.isRegularFileKey],
                                                options: [.skipsHiddenFiles])!
        var tasks: [String: Task<String?, Error>] = [:]
        for case let url as URL in enumerator {
            let fileNameWOExtension = url.deletingPathExtension().lastPathComponent
            let specsName = fileNameWOExtension.components(separatedBy: "_")[0]
            if let dataParser = formatDataParserDict[specsName] {
                tasks[fileNameWOExtension] = Task {
                    let data = try String(contentsOfFile: url.path)
                    return try await dataParser.parseData(data) as? String
                }
            }
        }
        for (fileName, task) in tasks {
            do {
                guard let output = try await task.value else {
                    throw MainError.runtimeError("Output string is nil")
                }
                let outputURL = URL(fileURLWithPath: "\(outputPath)/\(fileName).ndjson")
                try output.write(to: outputURL, atomically: true, encoding: .utf8)
                logger.info("Parsed data: \(fileName)")
            } catch {
                logger.error("Error while parsing data '\(fileName)': \(error.localizedDescription)")
            }
        }
    }
}
