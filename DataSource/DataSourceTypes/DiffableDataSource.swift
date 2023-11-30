//
//  DiffableDataSource.swift
//  DataSource
//
//  Created by Vadim Yelagin on 10/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import Combine

/// `DataSource` implementation that has one section of items of type T.
///
/// Whenever the array of items is changed, the autoDiffDataSource compares
/// each pair of old and new items
///
public final class DiffableDataSource: DataSource {

	public let changes: AnyPublisher<DataChange, Never>
	private let changesSubject = PassthroughSubject<DataChange, Never>()
	private var cancellable: Cancellable?

	public var sections: [DataSourceSection] {
		return [DataSourceSection(items: items.value)]
	}

	/// Mutable array of items in the only section of the autoDiffDataSource.
	///
	/// Every modification of the array causes calculation
	/// and emission of appropriate dataChanges.
	public let items: CurrentValueSubject<[AnyHashable], Never>

	public let supplementaryItems: [String: Any]

	/// Creates an autoDiffDataSource.
	/// - parameters:
	///   - items: Initial array of items of the only section of the autoDiffDataSource.
	///   - supplementaryItems: Supplementary items of the section.
	public init(
		_ items: [AnyHashable] = [],
		supplementaryItems: [String: Any] = [:])
	{
		self.changes = changesSubject.eraseToAnyPublisher()
		self.items = CurrentValueSubject(items)
		self.supplementaryItems = supplementaryItems

		cancellable = self.items
			.map { DataChangeApply(sections: [DataSourceSection(items: $0)]) }
			.sink { [weak self] in self?.changesSubject.send($0) }
	}


	deinit {
		cancellable?.cancel()
	}

	public let numberOfSections = 1

	public func numberOfItemsInSection(_ section: Int) -> Int {
		return self.items.value.count
	}

	public func supplementaryItemOfKind(_ kind: String, inSection section: Int) -> Any? {
		return self.supplementaryItems[kind]
	}

	public func item(at indexPath: IndexPath) -> Any {
		return self.items.value[indexPath.item]
	}

	public func leafDataSource(at indexPath: IndexPath) -> (DataSource, IndexPath) {
		return (self, indexPath)
	}

}
