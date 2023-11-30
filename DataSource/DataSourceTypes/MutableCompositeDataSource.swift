//
//  MutableCompositeDataSource.swift
//  DataSource
//
//  Created by Vadim Yelagin on 15/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import Combine

/// `DataSource` implementation that is composed of a mutable array
/// of other dataSources (called inner dataSources).
///
/// See `CompositeDataSource` for details.
///
/// The array of innerDataSources can be modified by calling methods that perform
/// individual changes and instantly make the dataSource emit
/// a corresponding dataChange.
public final class MutableCompositeDataSource: DataSource {

	public let changes: AnyPublisher<DataChange, Never>
	private let changesSubject = PassthroughSubject<DataChange, Never>()
	private var cancellables = Set<AnyCancellable>()

	private let _innerDataSources: CurrentValueSubject<[DataSource], Never>

	public var innerDataSources: CurrentValueSubject<[DataSource], Never> {
		return _innerDataSources
	}

	public var sections: [DataSourceSection] {
		_innerDataSources.value.flatMap { $0.sections }
	}

	public init(_ inner: [DataSource] = []) {
		changes = changesSubject.eraseToAnyPublisher()
		_innerDataSources = CurrentValueSubject(inner)

		inner.forEach { datasource in
			datasource.changes.sink { [weak self] _ in
				if let self = self {
					self.changesSubject.send(DataChangeApply(sections: self.sections))
				}
			}.store(in: &cancellables)
		}
	}

	public var numberOfSections: Int {
		return _innerDataSources.value.reduce(0) { subtotal, dataSource in
			return subtotal + dataSource.numberOfSections
		}
	}

	public func numberOfItemsInSection(_ section: Int) -> Int {
		let (index, innerSection) = mapInside(_innerDataSources.value, section)
		return _innerDataSources.value[index].numberOfItemsInSection(innerSection)
	}

	public func supplementaryItemOfKind(_ kind: String, inSection section: Int) -> Any? {
		let (index, innerSection) = mapInside(_innerDataSources.value, section)
		return _innerDataSources.value[index].supplementaryItemOfKind(kind, inSection: innerSection)
	}

	public func item(at indexPath: IndexPath) -> Any {
		let (index, innerSection) = mapInside(_innerDataSources.value, indexPath.section)
		let innerPath = indexPath.ds_setSection(innerSection)
		return _innerDataSources.value[index].item(at: innerPath)
	}

	public func leafDataSource(at indexPath: IndexPath) -> (DataSource, IndexPath) {
		let (index, innerSection) = mapInside(_innerDataSources.value, indexPath.section)
		let innerPath = indexPath.ds_setSection(innerSection)
		return _innerDataSources.value[index].leafDataSource(at: innerPath)
	}

	/// Inserts a given inner dataSource at a given index
	/// and emits `DataChangeInsertSections` for its sections.
	public func insert(_ dataSource: DataSource, at index: Int) {
		insert([dataSource], at: index)
	}

	/// Inserts an array of dataSources at a given index
	/// and emits `DataChangeInsertSections` for their sections.
	public func insert(_ dataSources: [DataSource], at index: Int) {
		_innerDataSources.value.insert(contentsOf: dataSources, at: index)
		changesSubject.send(DataChangeApply(sections: sections))
	}

	/// Deletes an inner dataSource at a given index
	/// and emits `DataChangeDeleteSections` for its sections.
	public func delete(at index: Int) {
		delete(in: Range(index...index))
	}

	/// Deletes an inner dataSource in the given range
	/// and emits `DataChangeDeleteSections` for its corresponding sections.
	public func delete(in range: Range<Int>) {
		_innerDataSources.value.removeSubrange(range)
		changesSubject.send(DataChangeApply(sections: sections))
	}

	/// Replaces an inner dataSource at a given index with another inner dataSource
	/// and emits a batch of `DataChangeDeleteSections` and `DataChangeInsertSections`
	/// for their sections.
	public func replaceDataSource(at index: Int, with dataSource: DataSource) {
		_innerDataSources.value[index] = dataSource
		changesSubject.send(DataChangeApply(sections: sections))
	}

	/// Moves an inner dataSource at a given index to another index
	/// and emits a batch of `DataChangeMoveSection` for its sections.
	public func moveData(at oldIndex: Int, to newIndex: Int) {
		let dataSource = _innerDataSources.value.remove(at: oldIndex)
		_innerDataSources.value.insert(dataSource, at: newIndex)
		changesSubject.send(DataChangeApply(sections: sections))
	}

	private func sections(of dataSource: DataSource, at index: Int) -> [Int] {
		let location = mapOutside(_innerDataSources.value, index)(0)
		let length = dataSource.numberOfSections
		return Array(location ..< location + length)
	}

	private func sectionsOfDataSource(at index: Int) -> [Int] {
		let dataSource = _innerDataSources.value[index]
		return sections(of: dataSource, at: index)
	}

}
