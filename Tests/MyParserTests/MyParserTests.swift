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

class DataParserTests: XCTestCase {
    func testParseDataWithStubCallback() async throws {
        let csv = """
        column name,width,datatype
        name,10,TEXT
        valid,1,BOOLEAN
        count,3,INTEGER
        """
        let specs = try await parseSpecs(csv)
        let dataParser = DataParser(specs)
        let data = """
        Diabetes  1  1
        Asthma    0-14
        Stroke    1122
        """
        let stubCallback: OutputCallback = { input in return input }
        let parsedData = try await dataParser.parseData(data, callback: stubCallback) as? [LineResultType]
        XCTAssertEqual(parsedData?[0][0].0, "name")
        XCTAssertEqual(parsedData?[0][0].1 as? String, "Diabetes")
        XCTAssertEqual(parsedData?[0][1].0, "valid")
        XCTAssertEqual(parsedData?[0][1].1 as? Bool, true)
        XCTAssertEqual(parsedData?[0][2].0, "count")
        XCTAssertEqual(parsedData?[0][2].1 as? Int, 1)
        XCTAssertEqual(parsedData?[1][0].0, "name")
        XCTAssertEqual(parsedData?[1][0].1 as? String, "Asthma")
        XCTAssertEqual(parsedData?[1][1].0, "valid")
        XCTAssertEqual(parsedData?[1][1].1 as? Bool, false)
        XCTAssertEqual(parsedData?[1][2].0, "count")
        XCTAssertEqual(parsedData?[1][2].1 as? Int, -14)
        XCTAssertEqual(parsedData?[2][0].0, "name")
        XCTAssertEqual(parsedData?[2][0].1 as? String, "Stroke")
        XCTAssertEqual(parsedData?[2][1].0, "valid")
        XCTAssertEqual(parsedData?[2][1].1 as? Bool, true)
        XCTAssertEqual(parsedData?[2][2].0, "count")
        XCTAssertEqual(parsedData?[2][2].1 as? Int, 122)
    }

    func testParseDataWithNDJSONOutputCallback() async throws {
        let csv = """
        column name,width,datatype
        name,10,TEXT
        valid,1,BOOLEAN
        count,3,INTEGER
        """
        let specs = try await parseSpecs(csv)
        let dataParser = DataParser(specs)
        let data = """
        Diabetes  1  1
        Asthma    0-14
        Stroke    1122
        """
        let parsedData = try await dataParser.parseData(data)
        XCTAssertEqual(parsedData as? String, """
        {"name": "Diabetes", "valid": true, "count": 1}
        {"name": "Asthma", "valid": false, "count": -14}
        {"name": "Stroke", "valid": true, "count": 122}

        """)
    }

    func testInvalidDataLength() async throws {
        let csv = """
        column name,width,datatype
        name,10,TEXT
        valid,1,BOOLEAN
        count,3,INTEGER
        """
        let specs = try await parseSpecs(csv)
        let dataParser = DataParser(specs)
        let data = """
        Diabetes  1  1
        Asthma    0-14
        Stroke    112
        """
        do {
            _ = try await dataParser.parseData(data)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? DataParserError, .invalidDataLength)
        }
    }

    func testInvalidLineEnd() async throws {
        let csv = """
        column name,width,datatype
        name,10,TEXT
        valid,1,BOOLEAN
        count,3,INTEGER
        """
        let specs = try await parseSpecs(csv)
        let dataParser = DataParser(specs)
        let data = """
        Diabetes  1  1/Asthma    0-14
        Stroke    1122
        """
        do {
            _ = try await dataParser.parseData(data)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? DataParserError, .invalidLineEnd)
        }
    }

    func testUnexpectedNewline() async throws {
        let csv = """
        column name,width,datatype
        name,10,TEXT
        valid,1,BOOLEAN
        count,3,INTEGER
        """
        let specs = try await parseSpecs(csv)
        let dataParser = DataParser(specs)
        let data = """
        Diabetes  1  1
        Asthma    0-14
        Stroke    1
        12
        """
        do {
            _ = try await dataParser.parseData(data)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? DataParserError, .unexpectedNewline)
        }
    }

    func testInvalidBooleanValue() async throws {
        let csv = """
        column name,width,datatype
        name,10,TEXT
        valid,1,BOOLEAN
        count,3,INTEGER
        """
        let specs = try await parseSpecs(csv)
        let dataParser = DataParser(specs)
        let data = """
        Diabetes  1  1
        Asthma    2-14
        Stroke    1122
        """
        do {
            _ = try await dataParser.parseData(data)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? DataParserError, .invalidBooleanValue)
        }
    }

    func testInvalidIntegerValueWithString() async throws {
        let csv = """
        column name,width,datatype
        name,10,TEXT
        valid,1,BOOLEAN
        count,3,INTEGER
        """
        let specs = try await parseSpecs(csv)
        let dataParser = DataParser(specs)
        let data = """
        Diabetes  1  1
        Asthma    0-14
        Stroke    1abc
        """
        do {
            _ = try await dataParser.parseData(data)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? DataParserError, .invalidIntegerValue)
        }
    }

    func testInvalidIntegerValueWithFloat() async throws {
        let csv = """
        column name,width,datatype
        name,10,TEXT
        valid,1,BOOLEAN
        count,3,INTEGER
        """
        let specs = try await parseSpecs(csv)
        let dataParser = DataParser(specs)
        let data = """
        Diabetes  1  1
        Asthma    0-14
        Stroke    11.2
        """
        do {
            _ = try await dataParser.parseData(data)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? DataParserError, .invalidIntegerValue)
        }
    }
}
