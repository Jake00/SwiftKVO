//
//  PropertyObserver.swift
//  PullToMenu
//
//  Created by Jake on 26/07/15.
//  Copyright (c) 2015 Jake000. All rights reserved.
//

import Foundation

/**
A `PropertyObserver` object is a small wrapper around Apple's KVO API which allows objects to automatically call separate fuctions for observed properties (ie. not pipe everything through `observeValueForKeyPath:ofObject:`.)

Its main purpose allows you to use KVO from pure Swift objects that do not inherit from `NSObject`, but which wish to observe properties on objects that do.
*/
public final class PropertyObserver: NSObject {
    
    /**
     The type signature of functions or closures which are registered to receive change callbacks. This takes the form of (oldValue, newValue).
     */
    public typealias ChangeCallback = (Any?, Any?) -> Void
    
    // MARK: - Public properties
    
    /**
    Dictionary of property keys that are being observed on the `observed` object, with callback functions.
    
    **Key**: The property key that is being observed.
    
    **Value**: The callback function that is invoked when a KVO notification is triggered. The objects that are passed through are the observed properties `oldValue` and `newValue` respectively, that is, the value before the attribute was changed, and the new value for the attribute.
    */
    public var events: [String: ChangeCallback] {
        didSet {
            guard isObserving else { return }
            // Stop observing any values that are no longer present in the dictionary,
            // and begin observing new values that are now present.
            let oldObservedEvents = Array(oldValue.keys.filter { self.events[$0] == nil })
            let newObservedEvents = Array(events.keys.filter { oldValue[$0] == nil })
            endObserving(oldObservedEvents)
            beginObserving(newObservedEvents)
        }
    }
    
    /**
    Whether or not this class is currently observing any KVO events on the `observed` object.
    
    Setting this value will begin or end observing the property keys given in the `events` dictionary.
    */
    public var isObserving: Bool {
        didSet {
            if isObserving != oldValue {
                (isObserving ? beginObserving : endObserving)(Array(events.keys))
            }
        }
    }
    
    // MARK: Private
    
    /// Private context used to ensure this class passes on other KVO events it did not register itself.
    private static var context: Int = 1
    
    /// The object whom we are observing property changes on.
    private let observed: NSObject
    
    // MARK: - Lifecycle
    
    /**
    Initializes a new `PropertyObserver` object which listens for changes on a given object.
    
    - parameter observed: The object to listen for KVO events.
    - parameter events: Optional dictionary of property keys to listen for.
    - parameter isInitiallyObserving: Optional boolean to start observing events immediately.
    */
    public init(observed: NSObject, events: [String: ChangeCallback] = [:], isInitiallyObserving: Bool = true) {
        self.observed = observed
        self.events = events
        self.isObserving = isInitiallyObserving
        
        super.init()
        
        if isInitiallyObserving {
            beginObserving(Array(events.keys))
        }
    }
    
    deinit {
        self.isObserving = false
    }
    
    // MARK: - Update
    
    /**
    Updates the `events` dictionary by adding the keys and values provided, and starts observing the newly added properties.
    
    - parameter events: The keys and values to be appended to the `events` dictionary.
    */
    public func add(events: [String: ChangeCallback]) {
        var newEvents = self.events
        for (k, v) in events {
            newEvents.updateValue(v, forKey: k)
        }
        self.events = newEvents
    }
    
    /**
    Updates the `events` dictionary by removing the keys provided, and stops observing those properties automatically.
    
    - parameter events: The keys to be removed from the `events` dictionary.
    */
    public func remove(events: [String]) {
        var newEvents = self.events
        for k in events {
            newEvents.removeValue(forKey: k)
        }
        self.events = newEvents
    }
    
    // MARK: - Key Value Observation
    
    private func beginObserving(_ keyPaths: [String]) {
        for keyPath in keyPaths {
            observed.addObserver(self, forKeyPath: keyPath, options: [.old, .new], context: &PropertyObserver.context)
        }
    }
    
    private func endObserving(_ keyPaths: [String]) {
        for keyPath in keyPaths {
            observed.removeObserver(self, forKeyPath: keyPath, context: &PropertyObserver.context)
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &PropertyObserver.context else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if let keyPath = keyPath, let change = change, let event = events[keyPath] {
            event(change[.oldKey], change[.newKey])
        }
    }
}
