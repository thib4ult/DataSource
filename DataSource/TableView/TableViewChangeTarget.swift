//
//  TableViewChangeTarget.swift
//  DataSource
//
//  Created by Vadim Yelagin on 09/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import UIKit

extension UITableView: DataChangeTarget {

	public func ds_apply(_ sections: [DataSourceSection]) {
		guard let diffableDataSource = self.dataSource as? UITableViewDiffableDataSource<Int, AnyHashable> else {
			return
		}
		var snapshot = NSDiffableDataSourceSnapshot<Int, AnyHashable>()
		sections.forEach { section in
			snapshot.appendSections([section.hashValue])
			snapshot.appendItems(section.items, toSection: section.hashValue)
		}
		diffableDataSource.apply(snapshot, animatingDifferences: true)
	}

	public func ds_deleteItems(_ items: [AnyHashable]) {
		guard let diffableDataSource = self.dataSource as? UITableViewDiffableDataSource<Int, AnyHashable> else {
			return
		}
		var snapshot = NSDiffableDataSourceSnapshot<Int, AnyHashable>()
		snapshot.deleteItems(items)
		diffableDataSource.apply(snapshot, animatingDifferences: true)
	}

	public func ds_deleteSections(_ sections: [DataSourceSection]) {
		guard let diffableDataSource = self.dataSource as? UITableViewDiffableDataSource<Int, AnyHashable> else {
			return
		}
		var snapshot = NSDiffableDataSourceSnapshot<Int, AnyHashable>()
		snapshot.deleteSections(sections.map { $0.hashValue })
		diffableDataSource.apply(snapshot, animatingDifferences: true)	}

	public func ds_insertItems(_ items: [AnyHashable], at beforeItem: AnyHashable) {
		guard let diffableDataSource = self.dataSource as? UITableViewDiffableDataSource<Int, AnyHashable> else {
			return
		}
		var snapshot = NSDiffableDataSourceSnapshot<Int, AnyHashable>()
		snapshot.insertItems(items, beforeItem: beforeItem)
		diffableDataSource.apply(snapshot, animatingDifferences: true)
	}

	public func ds_insertSections(_ sections: [DataSourceSection], at beforeSection: DataSourceSection) {
		guard let diffableDataSource = self.dataSource as? UITableViewDiffableDataSource<Int, AnyHashable> else {
			return
		}
		var snapshot = NSDiffableDataSourceSnapshot<Int, AnyHashable>()
		snapshot.insertSections(sections.map { $0.hashValue }, beforeSection: beforeSection.hashValue)
		diffableDataSource.apply(snapshot, animatingDifferences: true)
	}

	public func ds_moveItem(_ item: AnyHashable, at beforeItem: AnyHashable) {
		guard let diffableDataSource = self.dataSource as? UITableViewDiffableDataSource<Int, AnyHashable> else {
			return
		}
		var snapshot = NSDiffableDataSourceSnapshot<Int, AnyHashable>()
		snapshot.moveItem(item, beforeItem: beforeItem)
		diffableDataSource.apply(snapshot, animatingDifferences: true)
	}

	public func ds_moveSection(_ section: DataSourceSection, at index: Int) {
		guard let diffableDataSource = self.dataSource as? UITableViewDiffableDataSource<Int, AnyHashable> else {
			return
		}
		var snapshot = NSDiffableDataSourceSnapshot<Int, AnyHashable>()
		snapshot.moveSection(section.hashValue, beforeSection: index)
		diffableDataSource.apply(snapshot, animatingDifferences: true)
	}

	public func ds_reloadItems(_ items: [AnyHashable]) {
		guard let diffableDataSource = self.dataSource as? UITableViewDiffableDataSource<Int, AnyHashable> else {
			return
		}
		var snapshot = NSDiffableDataSourceSnapshot<Int, AnyHashable>()
		snapshot.reloadItems(items)
		diffableDataSource.apply(snapshot, animatingDifferences: true)
	}

	public func ds_reloadSections(_ sections: [DataSourceSection]) {
		guard let diffableDataSource = self.dataSource as? UITableViewDiffableDataSource<Int, AnyHashable> else {
			return
		}
		var snapshot = NSDiffableDataSourceSnapshot<Int, AnyHashable>()
		snapshot.reloadSections(sections.map { $0.hashValue })
		diffableDataSource.apply(snapshot, animatingDifferences: true)
	}

}
