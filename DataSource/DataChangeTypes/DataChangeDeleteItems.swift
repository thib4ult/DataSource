//
//  DataChangeDeleteItems.swift
//  DataSource
//
//  Created by Vadim Yelagin on 09/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation

public struct DataChangeDeleteItems<T: Hashable>: DataChange {

	public let items: [T]

	public init(_ items: [T]) {
		self.items = items
	}

	public func apply(to target: DataChangeTarget) {
		target.ds_deleteItems(items)
	}

}
