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

	public var changes: AnyPublisher<DataChange, Never> {
		changesSubject.eraseToAnyPublisher()
	}
	private let changesSubject = PassthroughSubject<DataChange, Never>()

	@Published public var innerDataSource: DataSource

	private var lastCancellable: Cancellable?
	private var cancellable: Cancellable?

	/// When `true`, switching innerDataSource produces
	/// a dataChange consisting of deletions of all the
	/// sections of the old inner dataSource and insertion of all
	/// the sections of the new innerDataSource.
	///
	/// when `false`, switching innerDataSource produces `DataChangeReloadData`.
	@Published public var animatesChanges: Bool

	public init(_ inner: DataSource = EmptyDataSource(), animateChanges: Bool = true) {
		self.innerDataSource = inner
		self.animatesChanges = animateChanges
		lastCancellable = inner.changes.sink { [weak self] in self?.changesSubject.send($0) }

		let combinePrevious = self.$innerDataSource
			.scan((inner, inner)) { ($0.1, $1) }
			.dropFirst()
			.eraseToAnyPublisher()

		cancellable = combinePrevious.sink { [weak self] old, new in
				if let self = self {
					self.lastCancellable?.cancel()
					self.changesSubject.send(changeDataSources(old, new, self.animatesChanges))
					self.lastCancellable = new.changes.sink { [weak self] in self?.changesSubject.send($0) }
				}
			}
	}

	deinit {
		cancellable?.cancel()
		lastCancellable?.cancel()
	}

	public var numberOfSections: Int {
		let inner = self.innerDataSource
		return inner.numberOfSections
	}

	public func numberOfItemsInSection(_ section: Int) -> Int {
		let inner = self.innerDataSource
		return inner.numberOfItemsInSection(section)
	}

	public func supplementaryItemOfKind(_ kind: String, inSection section: Int) -> Any? {
		let inner = self.innerDataSource
		return inner.supplementaryItemOfKind(kind, inSection: section)
	}

	public func item(at indexPath: IndexPath) -> Any {
		let inner = self.innerDataSource
		return inner.item(at: indexPath)
	}

	public func leafDataSource(at indexPath: IndexPath) -> (DataSource, IndexPath) {
		let inner = self.innerDataSource
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
