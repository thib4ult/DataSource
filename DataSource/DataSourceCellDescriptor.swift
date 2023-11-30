import UIKit

public class CellDescriptor: NSObject {
	public let reuseIdentifier: String
	public let prototypeSource: PrototypeSource
	public let isMatching: (IndexPath, Any) -> Bool

	public init(
		_ reuseIdentifier: String,
		_ prototypeSource: PrototypeSource = .storyboard,
		isMatching: @escaping (IndexPath, Any) -> Bool)
	{
		self.reuseIdentifier = reuseIdentifier
		self.prototypeSource = prototypeSource
		self.isMatching = isMatching
	}

	public convenience init<Item>(
		_ reuseIdentifier: String,
		_ itemType: Item.Type,
		_ prototypeSource: PrototypeSource = .storyboard)
	{
		self.init(reuseIdentifier, prototypeSource) { $1 is Item }
	}
}

public class HeaderFooterDescriptor: NSObject {
	public let reuseIdentifier: String
	public let prototypeSource: PrototypeSource
	public let isMatching: (Int, Any) -> Bool

	public init(
		_ reuseIdentifier: String,
		_ prototypeSource: PrototypeSource,
		isMatching: @escaping (Int, Any) -> Bool)
	{
		self.reuseIdentifier = reuseIdentifier
		self.prototypeSource = prototypeSource
		self.isMatching = isMatching
	}

	public convenience init<Item>(
		_ reuseIdentifier: String,
		_ itemType: Item.Type,
		_ prototypeSource: PrototypeSource = .storyboard)
	{
		self.init(reuseIdentifier, prototypeSource) { $1 is Item }
	}
}

public enum PrototypeSource {
	case storyboard
	case nib(UINib)
	case `class`(AnyObject.Type)
	case headerNib(UINib)
	case `headerClass`(AnyObject.Type)
	case footerNib(UINib)
	case `footerClass`(AnyObject.Type)
}

extension CollectionViewDataSource {
	@objc open func configure(_ collectionView: UICollectionView, using cellDescriptors: [CellDescriptor], headerFooterDescriptors: [HeaderFooterDescriptor] = []) {
		self.reuseIdentifierForItem = { indexPath, item in
			for descriptor in cellDescriptors where descriptor.isMatching(indexPath, item) {
				return descriptor.reuseIdentifier
			}
			fatalError("Unable to determine reuse identifier")
		}
		self.reuseIdentifierForSupplementaryItem = { _, section, item in
			for descriptor in headerFooterDescriptors where descriptor.isMatching(section, item) {
				return descriptor.reuseIdentifier
			}

			fatalError("Unable to determine reuse supplementary identifier")
		}
		for descriptor in cellDescriptors {
			switch descriptor.prototypeSource {
			case .storyboard:
				break
			case .nib(let nib):
				collectionView.register(nib, forCellWithReuseIdentifier: descriptor.reuseIdentifier)
			case .class(let type):
				collectionView.register(type, forCellWithReuseIdentifier: descriptor.reuseIdentifier)
			default:
				break
			}
		}

		for descriptor in headerFooterDescriptors {
			switch descriptor.prototypeSource {
			case .headerNib(let nib):
				collectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: descriptor.reuseIdentifier)
			case .headerClass(let type):
				collectionView.register(type, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: descriptor.reuseIdentifier)
			case .footerNib(let nib):
				collectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: descriptor.reuseIdentifier)
			case .footerClass(let type):
				collectionView.register(type, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: descriptor.reuseIdentifier)
			default:
				break
			}
		}
		self.collectionView = collectionView
	}
}

extension TableViewDataSource {
	@objc open func configure(_ tableView: UITableView, using cellDescriptors: [CellDescriptor]) {
		self.reuseIdentifierForItem = { indexPath, item in
			for descriptor in cellDescriptors where descriptor.isMatching(indexPath, item) {
				return descriptor.reuseIdentifier
			}
			fatalError()
		}
		for descriptor in cellDescriptors {
			switch descriptor.prototypeSource {
			case .storyboard:
				break
			case .nib(let nib):
				tableView.register(nib, forCellReuseIdentifier: descriptor.reuseIdentifier)
			case .class(let type):
				tableView.register(type, forCellReuseIdentifier: descriptor.reuseIdentifier)
			default:
				break
			}
		}
	}
}

extension TableViewDataSourceWithHeaderFooterViews {
	@objc open func configure(_ tableView: UITableView, using cellDescriptors: [CellDescriptor], headerFooterDescriptors: [HeaderFooterDescriptor]) {
		reuseIdentifierForHeaderItem = { section, item in
			for descriptor in headerFooterDescriptors where descriptor.isMatching(section, item) {
				return descriptor.reuseIdentifier
			}
			fatalError()
		}
		reuseIdentifierForFooterItem = { section, item in
			for descriptor in headerFooterDescriptors {
				if descriptor.isMatching(section, item) {
					return descriptor.reuseIdentifier
				}
			}
			fatalError()
		}

		for descriptor in headerFooterDescriptors {
			switch descriptor.prototypeSource {
			case .headerNib(let nib):
				tableView.register(nib, forHeaderFooterViewReuseIdentifier: descriptor.reuseIdentifier)
			case .headerClass(let type):
				tableView.register(type, forHeaderFooterViewReuseIdentifier: descriptor.reuseIdentifier)
			case .footerNib(let nib):
				tableView.register(nib, forHeaderFooterViewReuseIdentifier: descriptor.reuseIdentifier)
			case .footerClass(let type):
				tableView.register(type, forHeaderFooterViewReuseIdentifier: descriptor.reuseIdentifier)
			default:
				break
			}
		}

		configure(tableView, using: cellDescriptors)
	}

}

public protocol ReusableItem: AnyObject {
	static var reuseIdentifier: String { get }
}

public protocol ReusableNib: AnyObject {
	static var nib: UINib { get }
}

extension ReusableItem where Self: UIView {
	public static var reuseIdentifier: String { return String(describing: self).components(separatedBy: ".").last! }
}

extension ReusableNib where Self: UIView, Self: ReusableItem {
	public static var nib: UINib { return UINib(nibName: self.reuseIdentifier, bundle: nil) }
}
