import XCTest
import CoreData
@testable import JobFinder

final class PersistenceControllerTests: XCTestCase {

    func testDefaultInitContainerName() {
        let pc = PersistenceController()
        XCTAssertEqual(pc.container.name, "Model",
                       "Имя контейнера должно браться из конструктора")
    }

    func testInMemoryStoreUsesDevNull() {
        let pc = PersistenceController(inMemory: true)
        guard let desc = pc.container.persistentStoreDescriptions.first else {
            return XCTFail("Должен быть хотя бы один persistentStoreDescription")
        }
        XCTAssertEqual(desc.url?.path, "/dev/null",
                       "In-memory store должен мапиться на /dev/null")
    }

    func testLoadPersistentStoresDoesNotThrow() {
        XCTAssertNoThrow(PersistenceController(inMemory: false))
        XCTAssertNoThrow(PersistenceController(inMemory: true))
    }
}
