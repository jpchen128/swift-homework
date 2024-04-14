import XCTest
@testable import MyParser

class SpecsParserTests: XCTestCase {
    func testParseSpecs() async throws {
        let csv = """
        column name,width,datatype
        name,10,TEXT
        valid,1,BOOLEAN
        count,3,INTEGER
        """
        let specs = try await parseSpecs(csv)
        XCTAssertEqual(specs, [
            Spec(columnName: "name", width: 10, dataType: .text),
            Spec(columnName: "valid", width: 1, dataType: .boolean),
            Spec(columnName: "count", width: 3, dataType: .integer)
        ])
    }

    func testInvalidDataType() async throws {
        let csv = """
        column name,width,datatype
        name,10,TEXT
        valid,1,FLOAT
        count,3,INTEGER
        """
        do {
            _ = try await parseSpecs(csv)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? SpecsParserError, .invalidDataType)
        }
    }

    func testInvalidCSVColumnName() async throws {
        let csv = """
        column name,length,data type
        name,10,TEXT
        valid,1,BOOLEAN
        count,3,INTEGER
        """
        do {
            _ = try await parseSpecs(csv)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? SpecsParserError, .invalidCSVColumnName)
        }
    }

    func testDuplicateSpecColumnName() async throws {
        let csv = """
        column name,width,datatype
        name,10,TEXT
        name,5,TEXT
        """
        do {
            _ = try await parseSpecs(csv)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? SpecsParserError, .duplicateSpecColumnName)
        }
    }
}
