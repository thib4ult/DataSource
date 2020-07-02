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
public final class MutableDataSource: DataSource {

	public var sections: [DataSourceSection] {
		return [DataSourceSection(items: items.value)]
	}

	public let changes: AnyPublisher<DataChange, Never>
	private let changesSubject = PassthroughSubject<DataChange, Never>()

	private let _items: CurrentValueSubject<[AnyHashable], Never>

	public var items: CurrentValueSubject<[AnyHashable], Never> {
		return _items
	}

	public let supplementaryItems: [String: Any]

	public init(_ items: [AnyHashable] = [], supplementaryItems: [String: Any] = [:]) {
		self.changes = changesSubject.eraseToAnyPublisher()
		_items = CurrentValueSubject(items)
		self.supplementaryItems = supplementaryItems
	}

	public let numberOfSections = 1

	public func numberOfItemsInSection(_ section: Int) -> Int {
		return self._items.value.count
	}

	public func supplementaryItemOfKind(_ kind: String, inSection section: Int) -> Any? {
		return self.supplementaryItems[kind]
	}

	public func item(at indexPath: IndexPath) -> Any {
		return self._items.value[indexPath.item]
	}

	public func leafDataSource(at indexPath: IndexPath) -> (DataSource, IndexPath) {
		return (self, indexPath)
	}

	/// Inserts a given item at a given index
	/// and emits `DataChangeInsertItems`.
	public func insertItem(_ item: AnyHashable, at index: Int) {
		self.insertItems([item], at: index)
	}

	/// Inserts items at a given index
	/// and emits `DataChangeInsertItems`.
	public func insertItems(_ items: [AnyHashable], at index: Int) {
		self._items.value.insert(contentsOf: items, at: index)
		let item = self.item(at: z(index)) as! AnyHashable
		let change = DataChangeInsertItems(items, at: item)
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
		self._items.value.removeSubrange(range)
		let change = DataChangeDeleteItems(range.map(z))
		changesSubject.send(change)
	}

	/// Replaces an item at a given index with another item
	/// and emits `DataChangeReloadItems`.
	public func replaceItem(at index: Int, with item: AnyHashable) {
		self._items.value[index] = item
		let change = DataChangeReloadItems(z(index))
		changesSubject.send(change)
	}

	/// Moves an item at a given index to another index
	/// and emits `DataChangeMoveItem`.
	public func moveItem(at oldIndex: Int, to newIndex: Int) {
		let item = self._items.value.remove(at: oldIndex)
		let atItem = self._items.value.remove(at: newIndex)
		self._items.value.insert(item, at: newIndex)
		let change = DataChangeMoveItem(item, atItem: atItem)
		changesSubject.send(change)
	}

	/// Replaces all items with a given array of items
	/// and emits `DataChangeReloadSections`.
	public func replaceItems(with items: [AnyHashable]) {
		self._items.value = items
		let change = DataChangeReloadSections([DataSourceSection(items: items)])
		changesSubject.send(change)
	}

}

private func z(_ index: Int) -> IndexPath {
	return IndexPath(item: index, section: 0)
}
