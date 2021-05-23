//
//  Entities.swift
//  BETest
//
//  Created by Sergey Kazakov on 21.05.2021.
//

import Foundation

protocol EntityID: Hashable, Codable {

}

protocol Entity: Codable {
     // swiftlint:disable type_name
    associatedtype ID: EntityID

    var id: ID { get }
}

struct Entities<T>: Codable where T: Entity {
    private var storage: [T.ID: T] = [:]

    func all() -> [T] {
        return storage.map { $0.value }
    }

    func findById(_ id: T.ID) -> T? {
        return storage[id]
    }

    func findAllById(_ ids: [T.ID]) -> [T] {
        return ids
            .map { storage[$0] }
            .compactMap { $0 }
    }

    func find(where predicate: (T) -> Bool, cache: String? = nil) -> [T] {
        let items = storage.values.filter(predicate)
        return items
    }

    mutating func removeById(_ id: T.ID) {
        storage.removeValue(forKey: id)
    }

    mutating func removeAllById(_ ids: [T.ID]) {
        ids.forEach { storage.removeValue(forKey: $0) }
    }
    
    mutating func save(_ item: T, with updating: Merging<T, T> = .replace) {
        let updatedItem = storage[item.id].map { existing in
            updating.merge(existing, item)
        }
        storage[item.id] = updatedItem ?? item
    }

    mutating func saveAll(_ items: [T], with updating: Merging<T, T> = .replace) {
        items.forEach { save($0, with: updating) }
    }
}
