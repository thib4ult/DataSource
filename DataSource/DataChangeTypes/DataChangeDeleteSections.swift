//
//  DataChangeDeleteSections.swift
//  DataSource
//
//  Created by Vadim Yelagin on 09/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation

public struct DataChangeDeleteSections: DataChange {

	public let sections: [DataSourceSection]

	public init(_ sections: [DataSourceSection]) {
		self.sections = sections
	}

	public func apply(to target: DataChangeTarget) {
		target.ds_deleteSections(sections)
	}

}
