import Foundation

// Struct for parsing data according to given specifications
public struct DataParser {
    // Array of specs for the columns
    let specs: [Spec]

    // Length of a line in the data
    let lineLength: Int

    public init(_ specs: [Spec]) {
        self.specs = specs
        self.lineLength = 1 + specs.reduce(0) { $0 + $1.width }
    }

    // Function to parse data according to the specifications
    // It takes a string of data to parse and a callback function for output
    // It returns whatever the callback function returns
    public func parseData(_ data: String, callback: OutputCallback = ndjsonOutput) async throws -> Any {
        // If the data does not end with a newline, add one
        let data = !data.last!.isNewline ? data + "\r\n" : data
        guard data.count % lineLength == 0 else {
            throw DataParserError.invalidDataLength
        }

        // Split data into lines with line length, and check if lines end with a newline
        let numberOfLines = data.count / lineLength
        let lines: [Substring] = try (0..<numberOfLines).map { idx in
            let lineStartIndex = data.index(data.startIndex, offsetBy: idx * lineLength)
            let lineEndIndex = data.index(lineStartIndex, offsetBy: lineLength)
            let line = data[lineStartIndex..<lineEndIndex]
            guard line.last!.isNewline else {
                throw DataParserError.invalidLineEnd
            }
            return line
        }

        // Parse each line and convert fields according to the specs
        let results = try lines.map { line in
            var currentStart = line.startIndex
            return try specs.map { spec in
                let currentEnd = line.index(currentStart, offsetBy: spec.width)
                let field = line[currentStart..<currentEnd]
                guard !field.contains(where: \.isNewline) else {
                    throw DataParserError.unexpectedNewline
                }
                currentStart = currentEnd
                return (spec.columnName, try spec.convert(String(field)))
            }
        }

        return try callback(results)
    }
}

// Callback function to output parsed data in NDJSON format
// It is the default output callback for DataParser
// It takes an array of line results and returns a string in NDJSON format
public func ndjsonOutput(_ results: [LineResultType]) throws -> String {
    let output = results.reduce("") { output, rowResult in
        output + "{" + (rowResult.reduce("") { output, columnResult in
            let jsonValue = columnResult.1 is String ? "\"\(columnResult.1)\"" : "\(columnResult.1)"
            return output + "\"\(columnResult.0)\": \(jsonValue), "
        }).dropLast(2) + "}\n"
    }
    return output
}
