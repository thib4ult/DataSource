//
//  DataChangeMoveSection.swift
//  DataSource
//
//  Created by Vadim Yelagin on 09/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation

public struct DataChangeMoveSection: DataChange {

	public let section: DataSourceSection
	public let toSection: Int

	public init(from fromSection: DataSourceSection, to toSection: Int) {
		self.section = fromSection
		self.toSection = toSection
	}

	public func apply(to target: DataChangeTarget) {
		target.ds_moveSection(section, at: toSection)
	}

}
