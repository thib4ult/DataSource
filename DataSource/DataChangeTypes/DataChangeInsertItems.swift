//
//  DataChangeInsertItems.swift
//  DataSource
//
//  Created by Vadim Yelagin on 09/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation

public struct DataChangeInsertItems<T: Hashable>: DataChange {

	public let items: [T]
	public let afterItem: T

	public init (_ items: [T], at beforeItem: T) {
		self.items = items
		self.afterItem = beforeItem
	}

	public func apply(to target: DataChangeTarget) {
		target.ds_insertItems(items, at: afterItem)
	}

}
