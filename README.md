# Wilbur's Parser

## Features
- Multi-threaded async parsing
- Fault-tolerance: Error from one thread does not affect the whole process
- Modularity: Parser packed as independent library
- Extensibility: Library users can implement customized callbacks to handle results

## Usages
### Run Basic Example
Run with `specs/` & `data/` containing input files under current directory:
```
swift run homework
```
How to specify input/output directory (from --help)
```
USAGE: homework [--specs <specs>] [--data <data>] [--output <output>]
OPTIONS:
  -s, --specs <specs>     The path of specs CSV files to parse.
  -d, --data <data>       The path of data files to parse.
  -o, --output <output>   The output directory.
  -h, --help              Show help information.
```

### Run Streaming Example (Experimental)
Start server:
```
python3 Sources/Streaming/stream_server.py --source data/testformat.txt
```
Start client:
```
swift run streaming specs/testformat1.csv http://127.0.0.1:5000/ output/stream1.ndjson
```

### Run Unit Tests
```
swift test
```

## Source Structure
```
.
├── Sources/
│   ├── Homework/
│   │   └── Main.swift                  // Basic Function Implementation.
│   ├── MyParser/
│   │   ├── SpecsParser.swift           // Function to parse specs.
│   │   ├── DataParser.swift            // Struct to parse data strings in specified format,
│   │   |                               // with default callback to output string.
│   │   ├── Types.swift                 // Definition of spec and data type, with conversion
│   │   |                               // methods from certain input.
│   │   └── Error.swift                 // Error enumeration, all being catched in main func
│   └── Streaming/
│       ├── stream_server.py            // Flask server to stream data strings.
│       └── StreamClient.swift          // Stream reader parsing data in real-time.
├── Tests/
│   └── MyParserTests/
│       ├── SpecsParserTests.swift      // Containing 4 unit tests for SpecsParser.
│       └── DataParserTests.swift       // Containing 8 unit tests for DataParser.
└── Package.swift                       // Swift Package Manager configuration file.
```

## References
### Third-party Libraries Used
- Swift: [SwiftCSV](https://github.com/swiftcsv/SwiftCSV.git), [ArgumentParser](https://github.com/apple/swift-argument-parser.git), [Swift Logging](https://github.com/apple/swift-log.git), [AsyncHTTPClient](https://github.com/swift-server/async-http-client)
- Python: [Flask](https://flask.palletsprojects.com/en/3.0.x/)

### Sources of Great Help
Explore structured concurrency in Swift:
https://developer.apple.com/videos/play/wwdc2021/10134/

### Coding Style
Swift Style Guide from Google: https://google.github.io/swift/
Linting tool: https://github.com/realm/SwiftLint
