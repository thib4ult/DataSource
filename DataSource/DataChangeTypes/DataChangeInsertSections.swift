//
//  DataChangeInsertSections.swift
//  DataSource
//
//  Created by Vadim Yelagin on 09/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation

public struct DataChangeInsertSections: DataChange {

	public let sections: [DataSourceSection]
	public let beforeSection: DataSourceSection

	public init(_ sections: [DataSourceSection], at beforeSection: DataSourceSection) {
		self.sections = sections
		self.beforeSection = beforeSection
	}

	public func apply(to target: DataChangeTarget) {
		target.ds_insertSections(sections, at: beforeSection)
	}

}
