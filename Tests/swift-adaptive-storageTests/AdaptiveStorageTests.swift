import XCTest
@testable import swift_adaptive_storage

final class swift_adaptive_storageTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(AdaptiveStorage().text, "Hello, World!")
        
        let adaptiveStorage = AdaptiveStorage()
        let content = try adaptiveStorage.testFileManager(content: "test lol")
        XCTAssertEqual(content, "test lol")
        
        try adaptiveStorage.runBenchmark()
        print("done")
    }
}
