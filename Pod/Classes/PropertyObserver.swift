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
public class PropertyObserver: NSObject {
    
    // MARK: - Public properties
    
    /**
    Dictionary of property keys that are being observed on the `observed` object, with callback functions.
    
    **Key**: The property key that is being observed.
    
    **Value**: The callback function that is invoked when a KVO notification is triggered. The objects that are passed through are the observed properties `oldValue` and `newValue` respectively, that is, the value before the attribute was changed, and the new value for the attribute.
    */
    public var events: [String: (AnyObject?, AnyObject?) -> Void] {
        didSet {
            if isObserving {
                // Stop observing any values that are no longer present in the dictionary,
                // and begin observing new values that are now present.
                endObserving(oldValue.keys.filter { self.events[$0] == nil }.array)
                beginObserving(events.keys.filter { oldValue[$0] == nil }.array)
            }
        }
    }
    
    /**
    Whether or not this class is currently observing any KVO events on the `observed` object.
    
    Setting this value will begin or end observing the property keys given in the `events` dictionary.
    */
    public var isObserving: Bool {
        willSet(newIsObserving) {
            if (newIsObserving != isObserving) {
                if (newIsObserving) {
                    beginObserving(events.keys.array)
                } else {
                    endObserving(events.keys.array)
                }
            }
        }
    }
    
    // MARK: Private
    
    /// Internal context used to ensure this class passes on other KVO events it did not register itself.
    private let context = UnsafeMutablePointer<Void>()
    
    /// The object whom we are observing property changes on.
    private let observed: NSObject
    
    // MARK: - Lifecycle
    
    /**
    Initializes a new `PropertyObserver` object which listens for changes on a given object.
    
    :param: observed The object to listen for KVO events.
    :param: events Optional dictionary of property keys to listen for.
    :param: isInitiallyObserving Optional boolean to start observing events immediately.
    */
    public init(observed: NSObject, events: [String: (AnyObject?, AnyObject?) -> Void] = [:], isInitiallyObserving: Bool = true) {
        self.observed = observed
        self.events = events
        self.isObserving = isInitiallyObserving
        
        super.init()
        
        if (isInitiallyObserving) {
            beginObserving(events.keys.array)
        }
    }
    
    deinit {
        self.isObserving = false
    }
    
    // MARK: - Update
    
    /**
    Updates the `events` dictionary by adding the keys and values provided, and starts observing the newly added properties.
    
    :param: events The keys and values to be appended to the `events` dictionary.
    */
    public func addEvents(events: [String: (AnyObject?, AnyObject?) -> Void]) {
        var newEvents = self.events
        for (k, v) in events {
            newEvents.updateValue(v, forKey: k)
        }
        self.events = newEvents
    }
    
    /**
    Updates the `events` dictionary by removing the keys provided, and stops observing those properties automatically.
    
    :param: events The keys to be removed from the `events` dictionary.
    */
    public func removeEvents(events: [String]) {
        var newEvents = self.events
        for k in events {
            newEvents.removeValueForKey(k)
        }
        self.events = newEvents
    }
    
    // MARK: - Key Value Observation
    
    private func beginObserving(keyPaths: [String]) {
        for keyPath in keyPaths {
            observed.addObserver(self, forKeyPath: keyPath, options: .Old | .New, context: context)
        }
    }
    
    private func endObserving(keyPaths: [String]) {
        for keyPath in keyPaths {
            observed.removeObserver(self, forKeyPath: keyPath, context: context)
        }
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == self.context {
            if let event = events[keyPath] {
                event(change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey])
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}