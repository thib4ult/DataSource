//
//  AutoDiffSectionsDataSource.swift
//  DataSource
//
//  Created by Vadim Yelagin on 14/08/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import Combine

/// `DataSource` implementation that has an arbitrary
/// number of sections of items of type T.
///
/// Whenever the array of sections is changed, the dataSource compares
/// each pair of old and new sections via `compareSections` function,
/// and produces minimal set of dataChanges that delete and insert
/// non-matching sections. Then it compares items (via `compareItems` function)
/// within each pair of matching sections and produces minimal sets of dataChanges
/// for non-matching items within those sections.
///
/// `AutoDiffSectionsDataSource` never generates movement of sections.
/// Items are only compared withing sections, hence movement of items
/// between sections are never found either.
///
/// When comparing sections, `AutoDiffSectionsDataSource` does not rely
/// on the items they comprise. Instead it calls `compareSections` that
/// you provide it with. Sections are usually compared based on some
/// userData that is used to identify them. Such data can be stored in
/// sections' `supplementaryItems` dictionary under some user-defined key.
public final class DiffableSectionsDataSource: DataSource {

	public let changes: AnyPublisher<DataChange, Never>
	private let changesSubject = PassthroughSubject<DataChange, Never>()

	private var cancellable: Cancellable?

	public var sections: [DataSourceSection] {
		set(newValue) {
			_sections.send(newValue)
		}
		get {
			_sections.value
		}
	}

	/// Mutable array of dataSourceSections.
	///
	/// Every modification of the array causes calculation
	/// and emission of appropriate dataChanges.
	private let _sections: CurrentValueSubject<[DataSourceSection], Never>

	/// Creates an autoDiffSectionsDataSource.
	/// - parameters:
	///   - sections: Initial array of sections of the autoDiffDataSource.
	public init(
		sections: [DataSourceSection] = [],
		animateChanges: Bool = true)
	{
		self.changes = changesSubject.eraseToAnyPublisher()
		self._sections = CurrentValueSubject(sections)

		cancellable = self._sections
			.map { DataChangeApply(sections: $0) }
			.sink { [weak self] in self?.changesSubject.send($0) }
	}

	deinit {
		cancellable?.cancel()
	}

	public var numberOfSections: Int {
		return self._sections.value.count
	}

	public func numberOfItemsInSection(_ section: Int) -> Int {
		return self._sections.value[section].items.count
	}

	public func supplementaryItemOfKind(_ kind: String, inSection section: Int) -> Any? {
		return self._sections.value[section].supplementaryItems[kind]
	}

	public func item(at indexPath: IndexPath) -> Any {
		return self._sections.value[indexPath.section].items[indexPath.item]
	}

	public func leafDataSource(at indexPath: IndexPath) -> (DataSource, IndexPath) {
		return (self, indexPath)
	}

}
