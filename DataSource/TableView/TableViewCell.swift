//
//  TableViewCell.swift
//  DataSource
//
//  Created by Vadim Yelagin on 04/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import UIKit
import Combine

/// `UITableViewCell` subclass that implements `DataSourceItemReceiver` protocol
/// by putting received dataSource items into a `MutableProperty` called `cellModel`.
/// - note:
///   You are not required to subclass `TableViewCell` class in order
///   to use your cell subclass with `TableViewDataSource`.
///   Instead you can implement `DataSourceItemReceiver`
///   protocol directly in any `UITableViewCell` subclass.
open class TableViewCell: UITableViewCell, DataSourceItemReceiver {

	public final let cellModel = CurrentValueSubject<Any?, Never>(nil)

	open func ds_setItem(_ item: Any) {
		self.cellModel.send(item)
	}

}
