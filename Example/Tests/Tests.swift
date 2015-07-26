import UIKit
import XCTest
import SwiftKVO

class Tests: XCTestCase {
    
    class SimpleTestClass: NSObject {
        dynamic var length = 0.0
        dynamic var name = ""
    }
    
    // Variables which are updated by the function calls.
    var lengthValueDidChangeInvocationCount = 0
    var nameValueDidChangeInvocationCount = 0
    var oldLengthValue = -1.0
    var newLengthValue = -1.0
    var oldNameValue = "-"
    var newNameValue = "-"
    
    var observed: SimpleTestClass!
    var events: [String: (AnyObject?, AnyObject?) -> Void]!
    
    override func setUp() {
        super.setUp()
        lengthValueDidChangeInvocationCount = 0
        nameValueDidChangeInvocationCount = 0
        oldLengthValue = -1.0
        newLengthValue = -1.0
        oldNameValue = "-"
        newNameValue = "-"
        
        observed = SimpleTestClass()
        events = [
            "length": lengthValueDidChange,
            "name": nameValueDidChange
        ]
    }
    
    // Functions which update the previous declared variables, and are invoked by KVO changes.
    
    func lengthValueDidChange(oldValue: AnyObject?, newValue: AnyObject?) {
        lengthValueDidChangeInvocationCount++
        if let oldValue = oldValue as? Double {
            oldLengthValue = oldValue
        }
        if let newValue = newValue as? Double {
            newLengthValue = newValue
        }
    }
    
    func nameValueDidChange(oldValue: AnyObject?, newValue: AnyObject?) {
        nameValueDidChangeInvocationCount++
        if let oldValue = oldValue as? String {
            oldNameValue = oldValue
        }
        if let newValue = newValue as? String {
            newNameValue = newValue
        }
    }
    
    // MARK: - Tests
    
    func testInitialization() {
        let observer = PropertyObserver(observed: observed, events: events, isInitiallyObserving: true)
        
        // Ensure no callbacks have been made.
        XCTAssertEqual(lengthValueDidChangeInvocationCount, 0, "No callbacks should occur from init")
        XCTAssertEqual(nameValueDidChangeInvocationCount, 0, "No callbacks should occur from init")
        XCTAssertEqual(oldLengthValue, -1.0, "No callbacks should occur from init")
        XCTAssertEqual(newLengthValue, -1.0, "No callbacks should occur from init")
        XCTAssertEqual(oldNameValue, "-", "No callbacks should occur from init")
        XCTAssertEqual(newNameValue, "-", "No callbacks should occur from init")
    }
    
    func testKVO() {
        let observer = PropertyObserver(observed: observed, events: events, isInitiallyObserving: true)
        
        // Change a property and ensure a callback has been made.
        observed.length = 2.0
        
        XCTAssertEqual(oldLengthValue, 0.0, "Old value should equal the initial value")
        XCTAssertEqual(newLengthValue, 2.0, "New value should equal the updated value")
        XCTAssertEqual(lengthValueDidChangeInvocationCount, 1, "Update function has been called once")
        
        XCTAssertEqual(oldNameValue, "-", "Name should not have been updated")
        XCTAssertEqual(newNameValue, "-", "Name should not have been updated")
        XCTAssertEqual(nameValueDidChangeInvocationCount, 0, "Name should not have been updated")
        
        observed.name = "Frederick"
        
        XCTAssertEqual(oldLengthValue, 0.0, "Length should not have been updated")
        XCTAssertEqual(newLengthValue, 2.0, "Length should not have been updated")
        XCTAssertEqual(lengthValueDidChangeInvocationCount, 1, "Length should not have been updated")
        
        XCTAssertEqual(oldNameValue, "", "Old value should equal the initial value")
        XCTAssertEqual(newNameValue, "Frederick", "New value should equal the updated value")
        XCTAssertEqual(nameValueDidChangeInvocationCount, 1, "Update function has been called once")
        
        observed.length = 4.0
        observed.length = 7.0
        observed.length = 9.0
        observed.length = 12.0
        observed.length = 5.0
        observed.length = -8.0
        observed.length = 200.0
        
        XCTAssertEqual(oldLengthValue, -8.0, "Old value should equal the previous updated value")
        XCTAssertEqual(newLengthValue, 200.0, "New value should equal the last updated value")
        XCTAssertEqual(lengthValueDidChangeInvocationCount, 8, "Update function has been called eight times in total")
        
        XCTAssertEqual(nameValueDidChangeInvocationCount, 1, "Name should not have been updated")
    }
    
    func testAddingEvents() {
        // Only observe length initially.
        let observer = PropertyObserver(observed: observed, events: [
            "length": lengthValueDidChange
            ], isInitiallyObserving: true)
        
        observed.name = "Frederick"
        observed.name = "James"
        observed.name = "Thomas"
        
        // Ensure no callbacks have been made as we are not observing name yet.
        XCTAssertEqual(nameValueDidChangeInvocationCount, 0, "No callbacks should occur")
        XCTAssertEqual(oldNameValue, "-", "No callbacks should occur")
        XCTAssertEqual(newNameValue, "-", "No callbacks should occur")
        
        observer.addEvents([
            "name": nameValueDidChange
            ])
        
        observed.name = "Christopher"
        observed.name = "Billy"
        
        XCTAssertEqual(nameValueDidChangeInvocationCount, 2, "Two callbacks should have occurred")
        XCTAssertEqual(oldNameValue, "Christopher", "Old value should equal the previous updated value")
        XCTAssertEqual(newNameValue, "Billy", "New value should equal the last updated value")
    }
    
    func testStopStartObserving() {
        let observer = PropertyObserver(observed: observed, events: events, isInitiallyObserving: false)
        
        // Not observing so no callbacks should be made.
        observed.length = 2.0
        observed.name = "Frederick"
        
        XCTAssertEqual(lengthValueDidChangeInvocationCount, 0, "No callbacks should have occurred")
        XCTAssertEqual(nameValueDidChangeInvocationCount, 0, "No callbacks should have occurred")
        XCTAssertEqual(oldLengthValue, -1.0, "No callbacks should have occurred")
        XCTAssertEqual(newLengthValue, -1.0, "No callbacks should have occurred")
        XCTAssertEqual(oldNameValue, "-", "No callbacks should have occurred")
        XCTAssertEqual(newNameValue, "-", "No callbacks should have occurred")
        
        observer.isObserving = true
        
        // These should trigger callbacks now.
        observed.length = 4.0
        observed.name = "Christopher"
        
        XCTAssertEqual(oldLengthValue, 2.0, "Old value should equal the previous updated value")
        XCTAssertEqual(oldNameValue, "Frederick", "Old value should equal the previous updated value")
        XCTAssertEqual(newLengthValue, 4.0, "New value should equal the updated value")
        XCTAssertEqual(newNameValue, "Christopher", "New value should equal the updated value")
        XCTAssertEqual(lengthValueDidChangeInvocationCount, 1, "Update function has been called once")
        XCTAssertEqual(nameValueDidChangeInvocationCount, 1, "Update function has been called once")
        
        observer.isObserving = false
        
        // Not observing so no callbacks should be made.
        observed.length = 8.0
        observed.name = "James"
        
        XCTAssertEqual(lengthValueDidChangeInvocationCount, 1, "No callbacks should have occurred")
        XCTAssertEqual(nameValueDidChangeInvocationCount, 1, "No callbacks should have occurred")
        XCTAssertEqual(oldLengthValue, 2.0, "No callbacks should have occurred")
        XCTAssertEqual(newLengthValue, 4.0, "No callbacks should have occurred")
        XCTAssertEqual(oldNameValue, "Frederick", "No callbacks should have occurred")
        XCTAssertEqual(newNameValue, "Christopher", "No callbacks should have occurred")
    }
}
