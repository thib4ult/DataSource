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

	public var changes: AnyPublisher<DataChange, Never> {
		changesSubject.eraseToAnyPublisher()
	}
	private let changesSubject = PassthroughSubject<DataChange, Never>()
	private var cancellable: Cancellable?

	@Published public var innerDataSources: [DataSource]

	public init(_ inner: [DataSource] = []) {
		innerDataSources = inner
		cancellable = $innerDataSources
			.map { changesOfInnerDataSources($0) }
			.switchToLatest()
			.sink { [weak self] in
				self?.changesSubject.send($0)
		}
	}

	deinit {
		cancellable?.cancel()
	}

	public var numberOfSections: Int {
		return innerDataSources.reduce(0) { subtotal, dataSource in
			return subtotal + dataSource.numberOfSections
		}
	}

	public func numberOfItemsInSection(_ section: Int) -> Int {
		let (index, innerSection) = mapInside(innerDataSources, section)
		return innerDataSources[index].numberOfItemsInSection(innerSection)
	}

	public func supplementaryItemOfKind(_ kind: String, inSection section: Int) -> Any? {
		let (index, innerSection) = mapInside(innerDataSources, section)
		return innerDataSources[index].supplementaryItemOfKind(kind, inSection: innerSection)
	}

	public func item(at indexPath: IndexPath) -> Any {
		let (index, innerSection) = mapInside(innerDataSources, indexPath.section)
		let innerPath = indexPath.ds_setSection(innerSection)
		return innerDataSources[index].item(at: innerPath)
	}

	public func leafDataSource(at indexPath: IndexPath) -> (DataSource, IndexPath) {
		let (index, innerSection) = mapInside(innerDataSources, indexPath.section)
		let innerPath = indexPath.ds_setSection(innerSection)
		return innerDataSources[index].leafDataSource(at: innerPath)
	}

	/// Inserts a given inner dataSource at a given index
	/// and emits `DataChangeInsertSections` for its sections.
	public func insert(_ dataSource: DataSource, at index: Int) {
		insert([dataSource], at: index)
	}

	/// Inserts an array of dataSources at a given index
	/// and emits `DataChangeInsertSections` for their sections.
	public func insert(_ dataSources: [DataSource], at index: Int) {
		innerDataSources.insert(contentsOf: dataSources, at: index)
		let sections = dataSources.enumerated().flatMap { self.sections(of: $1, at: index + $0) }
		if !sections.isEmpty {
			let change = DataChangeInsertSections(sections)
			changesSubject.send(change)
		}
	}

	/// Deletes an inner dataSource at a given index
	/// and emits `DataChangeDeleteSections` for its sections.
	public func delete(at index: Int) {
		delete(in: Range(index...index))
	}

	/// Deletes an inner dataSource in the given range
	/// and emits `DataChangeDeleteSections` for its corresponding sections.
	public func delete(in range: Range<Int>) {
		let sections = range.flatMap(sectionsOfDataSource)
		innerDataSources.removeSubrange(range)
		if !sections.isEmpty {
			let change = DataChangeDeleteSections(sections)
			changesSubject.send(change)
		}
	}

	/// Replaces an inner dataSource at a given index with another inner dataSource
	/// and emits a batch of `DataChangeDeleteSections` and `DataChangeInsertSections`
	/// for their sections.
	public func replaceDataSource(at index: Int, with dataSource: DataSource) {
		var batch: [DataChange] = []
		let oldSections = sectionsOfDataSource(at: index)
		if !oldSections.isEmpty {
			batch.append(DataChangeDeleteSections(oldSections))
		}
		let newSections = sections(of: dataSource, at: index)
		if !newSections.isEmpty {
			batch.append(DataChangeInsertSections(newSections))
		}
		innerDataSources[index] = dataSource
		if !batch.isEmpty {
			let change = DataChangeBatch(batch)
			changesSubject.send(change)
		}
	}

	/// Moves an inner dataSource at a given index to another index
	/// and emits a batch of `DataChangeMoveSection` for its sections.
	public func moveData(at oldIndex: Int, to newIndex: Int) {
		let oldLocation = mapOutside(innerDataSources, oldIndex)(0)
		let dataSource = innerDataSources.remove(at: oldIndex)
		innerDataSources.insert(dataSource, at: newIndex)
		let newLocation = mapOutside(innerDataSources, newIndex)(0)
		let numberOfSections = dataSource.numberOfSections
		let batch: [DataChange] = (0 ..< numberOfSections).map {
			DataChangeMoveSection(from: oldLocation + $0, to: newLocation + $0)
		}
		if !batch.isEmpty {
			let change = DataChangeBatch(batch)
			changesSubject.send(change)
		}
	}

	private func sections(of dataSource: DataSource, at index: Int) -> [Int] {
		let location = mapOutside(innerDataSources, index)(0)
		let length = dataSource.numberOfSections
		return Array(location ..< location + length)
	}

	private func sectionsOfDataSource(at index: Int) -> [Int] {
		let dataSource = innerDataSources[index]
		return sections(of: dataSource, at: index)
	}

}

private func changesOfInnerDataSources(_ innerDataSources: [DataSource]) -> AnyPublisher<DataChange, Never> {
	let arrayOfPublishers = innerDataSources.enumerated().map { index, dataSource in
		return dataSource.changes.map {
			$0.mapSections(mapOutside(innerDataSources, index))
		}.eraseToAnyPublisher()
	}

	return Publishers.MergeMany(arrayOfPublishers).eraseToAnyPublisher()
}
