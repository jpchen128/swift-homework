// Struct to hold the spec of a column
public struct Spec: Equatable {
    let columnName: String
    let width: Int
    let dataType: DataType
}

extension Spec {
    // Function to convert a string field to the data type of the spec
    func convert(_ data: String) throws -> Any {
        switch dataType {
        case .text:
            return data.trimmingCharacters(in: .whitespacesAndNewlines)
        case .boolean:
            switch data {
            case "0":
                return false
            case "1":
                return true
            default:
                throw DataParserError.invalidBooleanValue
            }
        case .integer:
            guard let int = Int(data.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                throw DataParserError.invalidIntegerValue
            }
            return int
        }
    }
}

// Type alias for the parsing result of a line
public typealias LineResultType = [(String, Any)]

// Type alias for the output callback function
public typealias OutputCallback = ([LineResultType]) throws -> Any

// Enum for the data type of a column, private to the module
enum DataType {
    case text
    case boolean
    case integer
}

extension DataType {
    init(_ string: String) throws {
        switch string {
        case "TEXT", "STRING":
            self = .text
        case "BOOLEAN":
            self = .boolean
        case "INTEGER":
            self = .integer
        default:
            throw SpecsParserError.invalidDataType
        }
    }
}
