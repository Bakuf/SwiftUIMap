//
//  WrappedCache.swift
//  
//
//  Created by Rodrigo Galvez on 07/05/23.
//

import Foundation

final class WrappedCache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private var allInsertedKeys : [String] = []
    
    func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value: value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        if let stringKey = key as? String {
            if !allInsertedKeys.contains(where: { $0 == stringKey }) {
                allInsertedKeys.append(stringKey)
            }
        }
    }
    
    func value(forKey key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }
    
    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
        if let stringKey = key as? String {
            if let index = allInsertedKeys.firstIndex(where: { $0 == stringKey } ) {
                allInsertedKeys.remove(at: index)
            }
        }
    }
    
    func removeAllValues() {
        wrapped.removeAllObjects()
        allInsertedKeys = []
    }
    
    func getAllStringKeys() -> [String] {
        return allInsertedKeys
    }
    
    func removeAllValuesWithIdentifier(prefix: String) {
        let keysToRemove = allInsertedKeys.filter( { $0.hasPrefix(prefix) } )
        for stringKey in keysToRemove {
            removeValue(forKey: stringKey as! Key)
        }
    }
}

extension WrappedCache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

extension WrappedCache {
    final class Entry {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }
}

extension WrappedCache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}
