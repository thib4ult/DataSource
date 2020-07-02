//
//  DataSourceSection.swift
//  DataSource
//
//  Created by Vadim Yelagin on 04/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation

public struct DataSourceSection: Hashable {
	public var items: [AnyHashable]
	public var supplementaryItems: [String: Any]

	public init(items: [AnyHashable], supplementaryItems: [String: Any] = [:]) {
		self.items = items
		self.supplementaryItems = supplementaryItems
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(items)
	}

	public static func == (lhs: DataSourceSection, rhs: DataSourceSection) -> Bool {
		lhs.items == rhs.items
	}

}
