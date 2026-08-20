import Foundation

public struct ActionManagerTests {
    public init() {}

    public func testActionManagerConfigurationAndDispatch() {
        let manager = ActionManager.shared
        manager.setAction(.takeScreenshot, for: .rightFront)

        let action = manager.getAction(for: .rightFront)
        assert(action == .takeScreenshot, "ActionManager should return .takeScreenshot for .rightFront quadrant")

        let record = manager.dispatchTap(quadrant: .rightFront)
        assert(record != nil, "Dispatch tap should generate a valid TapEventRecord")
        assert(record?.quadrant == .rightFront, "Record quadrant should be .rightFront")
    }

    public func testActionManagerDisabledQuadrant() {
        let manager = ActionManager.shared
        manager.setAction(.none, for: .leftRear)

        let record = manager.dispatchTap(quadrant: .leftRear)
        assert(record == nil, "Dispatching tap on disabled quadrant should return nil")
    }
}
