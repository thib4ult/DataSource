//
//  ProxyDataSource.swift
//  DataSource
//
//  Created by Vadim Yelagin on 04/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import Combine

/// `DataSource` implementation that returns data from
/// another dataSource (called inner dataSource).
///
/// The inner dataSource can be switched to a different
/// dataSource instance. In this case the proxyDataSource
/// emits a dataChange reloading its entire data.
///
/// ProxyDataSource listens to dataChanges of its inner dataSource
/// and emits them as its own changes.
public final class ProxyDataSource: DataSource {

	public let changes: AnyPublisher<DataChange, Never>
	private let changesSubject = PassthroughSubject<DataChange, Never>()

	public var innerDataSource: CurrentValueSubject<DataSource, Never>

	private var lastCancellable: Cancellable?

	/// When `true`, switching innerDataSource produces
	/// a dataChange consisting of deletions of all the
	/// sections of the old inner dataSource and insertion of all
	/// the sections of the new innerDataSource.
	///
	/// when `false`, switching innerDataSource produces `DataChangeReloadData`.
	public let animatesChanges: CurrentValueSubject<Bool, Never>

	public init(_ inner: DataSource = EmptyDataSource(), animateChanges: Bool = true) {
		changes = changesSubject.eraseToAnyPublisher()
		self.innerDataSource = CurrentValueSubject(inner)
		self.animatesChanges = CurrentValueSubject(animateChanges)
		lastCancellable = inner.changes.sink { [weak self] in self?.changesSubject.send($0) }

		let combinePrevious = self.innerDataSource
			.scan((inner, inner)) { ($0.1, $1) }
			.dropFirst(2)
			.eraseToAnyPublisher()

		_ = combinePrevious.sink { [weak self] old, new in
				if let self = self {
					self.lastCancellable?.cancel()
					self.changesSubject.send(changeDataSources(old, new, self.animatesChanges.value))
					self.lastCancellable = new.changes.sink { [weak self] in self?.changesSubject.send($0) }
				}
			}
	}

	deinit {
		self.lastCancellable?.cancel()
	}

	public var numberOfSections: Int {
		let inner = self.innerDataSource.value
		return inner.numberOfSections
	}

	public func numberOfItemsInSection(_ section: Int) -> Int {
		let inner = self.innerDataSource.value
		return inner.numberOfItemsInSection(section)
	}

	public func supplementaryItemOfKind(_ kind: String, inSection section: Int) -> Any? {
		let inner = self.innerDataSource.value
		return inner.supplementaryItemOfKind(kind, inSection: section)
	}

	public func item(at indexPath: IndexPath) -> Any {
		let inner = self.innerDataSource.value
		return inner.item(at: indexPath)
	}

	public func leafDataSource(at indexPath: IndexPath) -> (DataSource, IndexPath) {
		let inner = self.innerDataSource.value
		return inner.leafDataSource(at: indexPath)
	}

}

private func changeDataSources(_ old: DataSource, _ new: DataSource, _ animateChanges: Bool) -> DataChange {
	if !animateChanges {
		return DataChangeReloadData()
	}
	var batch: [DataChange] = []
	let oldSections = old.numberOfSections
	if oldSections > 0 {
		batch.append(DataChangeDeleteSections(Array(0 ..< oldSections)))
	}
	let newSections = new.numberOfSections
	if newSections > 0 {
		batch.append(DataChangeInsertSections(Array(0 ..< newSections)))
	}
	return DataChangeBatch(batch)
}
