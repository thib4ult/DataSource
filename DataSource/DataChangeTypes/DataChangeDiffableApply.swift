//
//  DataChangeDiffableApply.swift
//  DataSource
//
//  Created by Thibault Gauche on 02/07/2020.
//  Copyright © 2020 Thibault Gauche. All rights reserved.
//

import Foundation

public struct DataChangeApply: DataChange {

	let sections: [DataSourceSection]

	public init(sections: [DataSourceSection]) {
		self.sections = sections
	}

	public func apply(to target: DataChangeTarget) {
		target.ds_apply(sections)
	}
}
