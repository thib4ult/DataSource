//
//  DataChangeTarget.swift
//  DataSource
//
//  Created by Vadim Yelagin on 09/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation

/// A target onto which different types of dataChanges can be applied.
/// When a dataChange is applied, the target transitions from reflecting
/// the state of the corresponding dataSource prior to the dataChange
/// to reflecting the dataSource state after the dataChange.
///
/// `UITableView` and `UICollectionView` are implementing this protocol.
public protocol DataChangeTarget {

	func ds_apply(_ sections: [DataSourceSection])

	func ds_deleteItems(_ items: [AnyHashable])

	func ds_deleteSections(_ sections: [DataSourceSection])

	func ds_insertItems(_ items: [AnyHashable], at beforeItem: AnyHashable)

	func ds_insertSections(_ sections: [DataSourceSection], at beforeSection: DataSourceSection)

	func ds_moveItem(_ item: AnyHashable, at beforeItem: AnyHashable)

	func ds_moveSection(_ section: DataSourceSection, at index: Int)

	func ds_reloadItems(_ items: [AnyHashable])

	func ds_reloadSections(_ sections: [DataSourceSection])
}
