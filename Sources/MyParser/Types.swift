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

public struct Spec {
    let columnName: String
    let width: Int
    let dataType: DataType
}

extension Spec {
    func convert(_ data: String) -> Any {
        switch dataType {
        case .text:
            return data.trimmingCharacters(in: .whitespacesAndNewlines)
        case .boolean:
            return data == "1"
        case .integer:
            return Int(data.trimmingCharacters(in: .whitespacesAndNewlines))!
        }
    }
}

public typealias RowResultType = [(String, Any)]
public typealias OutputCallback = ([RowResultType]) throws -> String
