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

public struct Spec: Equatable {
    let columnName: String
    let width: Int
    let dataType: DataType
}

extension Spec {
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

public typealias LineResultType = [(String, Any)]
public typealias OutputCallback = ([LineResultType]) throws -> Any
