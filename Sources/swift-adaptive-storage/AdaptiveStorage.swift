import Foundation

public struct AdaptiveStorage {
    public private(set) var text = "Hello, World!"

    public init() {
    }
    
    public func testFileManager(content: String) throws -> String {
        let documentDirectoryUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let testFileUrl = documentDirectoryUrl.appending(path: "test.tst")
        try content.write(to: testFileUrl, atomically: true, encoding: .utf8)
        return try String(contentsOf: testFileUrl, encoding: .utf8)
    }
    
    public func runBenchmark() throws {
        //
        let a = try ContinuousClock().measure {
            try testFileManager(content: "test")
        }
        
        print(a)
    }
}
