//
//  DataChangeMoveItem.swift
//  DataSource
//
//  Created by Vadim Yelagin on 09/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation

public struct DataChangeMoveItem<T: Hashable>: DataChange {

	public let item: T
	public let beforeItem: T

	public init(_ item: T, atItem: T) {
		self.item = item
		self.beforeItem = atItem
	}

	public func apply(to target: DataChangeTarget) {
		target.ds_moveItem(item, at: beforeItem)
	}

}
