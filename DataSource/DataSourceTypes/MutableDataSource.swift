//
//  MutableDataSource.swift
//  DataSource
//
//  Created by Vadim Yelagin on 04/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import Combine

/// `DataSource` implementation that has one section of items of type T.
///
/// The array of items can be modified by calling methods that perform
/// individual changes and instantly make the dataSource emit
/// a corresponding dataChange.
public final class MutableDataSource<T>: DataSource {

	public var changes: AnyPublisher<DataChange, Never> {
		changesSubject.eraseToAnyPublisher()
	}
	private let changesSubject = PassthroughSubject<DataChange, Never>()

	@Published public var items: [T]

	public let supplementaryItems: [String: Any]

	public init(_ items: [T] = [], supplementaryItems: [String: Any] = [:]) {
		self.items = items
		self.supplementaryItems = supplementaryItems
	}

	public let numberOfSections = 1

	public func numberOfItemsInSection(_ section: Int) -> Int {
		return self.items.count
	}

	public func supplementaryItemOfKind(_ kind: String, inSection section: Int) -> Any? {
		return self.supplementaryItems[kind]
	}

	public func item(at indexPath: IndexPath) -> Any {
		return self.items[indexPath.item]
	}

	public func leafDataSource(at indexPath: IndexPath) -> (DataSource, IndexPath) {
		return (self, indexPath)
	}

	/// Inserts a given item at a given index
	/// and emits `DataChangeInsertItems`.
	public func insertItem(_ item: T, at index: Int) {
		self.insertItems([item], at: index)
	}

	/// Inserts items at a given index
	/// and emits `DataChangeInsertItems`.
	public func insertItems(_ items: [T], at index: Int) {
		self.items.insert(contentsOf: items, at: index)
		let change = DataChangeInsertItems(items.indices.map { z(index + $0) })
		changesSubject.send(change)
	}

	/// Deletes an item at a given index
	/// and emits `DataChangeDeleteItems`.
	public func deleteItem(at index: Int) {
		self.deleteItems(in: Range(index...index))
	}

	/// Deletes items in a given range
	/// and emits `DataChangeDeleteItems`.
	public func deleteItems(in range: Range<Int>) {
		self.items.removeSubrange(range)
		let change = DataChangeDeleteItems(range.map(z))
		changesSubject.send(change)
	}

	/// Replaces an item at a given index with another item
	/// and emits `DataChangeReloadItems`.
	public func replaceItem(at index: Int, with item: T) {
		self.items[index] = item
		let change = DataChangeReloadItems(z(index))
		changesSubject.send(change)
	}

	/// Moves an item at a given index to another index
	/// and emits `DataChangeMoveItem`.
	public func moveItem(at oldIndex: Int, to newIndex: Int) {
		let item = self.items.remove(at: oldIndex)
		self.items.insert(item, at: newIndex)
		let change = DataChangeMoveItem(from: z(oldIndex), to: z(newIndex))
		changesSubject.send(change)
	}

	/// Replaces all items with a given array of items
	/// and emits `DataChangeReloadSections`.
	public func replaceItems(with items: [T]) {
		self.items = items
		let change = DataChangeReloadSections([0])
		changesSubject.send(change)
	}

}

private func z(_ index: Int) -> IndexPath {
	return IndexPath(item: index, section: 0)
}
