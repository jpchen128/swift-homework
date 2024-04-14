import Foundation
import ArgumentParser
import MyParser
import Logging

let logger = Logger(label: "com.example.Homework")

@main
struct Homework: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "Homework",
        abstract: "A Swift command-line tool for parsing specific specs and data."
    )

    @Option(name: .shortAndLong, help: "The path of specs CSV files to parse.")
    var specs: String?

    @Option(name: .shortAndLong, help: "The path of data files to parse.")
    var data: String?

    @Option(name: .shortAndLong, help: "The output directory.")
    var output: String?

    func run() async throws {
        let specsPath = specs ?? "specs"
        let dataPath = data ?? "data"
        let outputPath = output ?? "output"
        var formatDataParserDict: [String: DataParser] = [:]
        do {
            if !FileManager.default.fileExists(atPath: outputPath) {
                try FileManager.default.createDirectory(atPath: outputPath,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }

            let csvEnumerator = FileManager.default.enumerator(
                                                at: URL(fileURLWithPath: specsPath),
                                                includingPropertiesForKeys: [.isRegularFileKey],
                                                options: [.skipsHiddenFiles])!
            var csvTasks: [String: Task<[Spec], Error>] = [:]
            for case let csvURL as URL in csvEnumerator {
                let specsName = csvURL.deletingPathExtension().lastPathComponent
                csvTasks[specsName] = Task {
                    let csv = try String(contentsOfFile: csvURL.path)
                    return try await parseSpecs(csv)
                }
            }
            for (specsName, task) in csvTasks {
                do {
                    let specs = try await task.value
                    formatDataParserDict[specsName] = DataParser(specs)
                    logger.info("Parsed specs: \(specsName)")
                } catch {
                    logger.error("Error while parsing '\(specsName)': \(error.localizedDescription)")
                }
            }

            let dataEnumerator = FileManager.default.enumerator(
                                                at: URL(fileURLWithPath: dataPath),
                                                includingPropertiesForKeys: [.isRegularFileKey],
                                                options: [.skipsHiddenFiles])!
            var dataTasks: [String: Task<String, Error>] = [:]
            for case let dataURL as URL in dataEnumerator {
                let fileNameWOExtension = dataURL.deletingPathExtension().lastPathComponent
                let specsName = fileNameWOExtension.components(separatedBy: "_")[0]
                if let dataParser = formatDataParserDict[specsName] {
                    dataTasks[fileNameWOExtension] = Task {
                        let data = try String(contentsOfFile: dataURL.path)
                        return try await dataParser.parseData(data)
                    }
                }
            }
            for (fileName, task) in dataTasks {
                do {
                    let output = try await task.value
                    let outputURL = URL(fileURLWithPath: "\(outputPath)/\(fileName).ndjson")
                    try output.write(to: outputURL, atomically: true, encoding: .utf8)
                    logger.info("Parsed data: \(fileName)")
                } catch {
                    logger.error("Error while parsing '\(fileName)': \(error.localizedDescription)")
                }
            }

        } catch {
            logger.error("Error: \(error.localizedDescription)")
        }
    }
}
