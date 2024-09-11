//
//  DropDownCellTableViewCell.swift
//  DropDown
//
//  Created by Kevin Hirsch on 28/07/15.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

#if os(iOS)

import UIKit

 class DropDownCell: UITableViewCell {

	//UI
	@IBOutlet  weak var optionLabel: UILabel!
	
	var selectedBackgroundColor: UIColor?
    var highlightTextColor: UIColor?
    var normalTextColor: UIColor?

}

//MARK: - UI

extension DropDownCell {
	override  func awakeFromNib() {
		super.awakeFromNib()
		
		backgroundColor = .clear
     //   optionLabel.textColor = .subtitleColor
	}
	
	override  var isSelected: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}
	
	override  var isHighlighted: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}
	
	override  func setHighlighted(_ highlighted: Bool, animated: Bool) {
		setSelected(highlighted, animated: animated)
	}
	
	override  func setSelected(_ selected: Bool, animated: Bool) {
		let executeSelection: () -> Void = { [weak self] in
			guard let `self` = self else { return }

			if let selectedBackgroundColor = self.selectedBackgroundColor {
				if selected {
					self.backgroundColor = selectedBackgroundColor
                    self.optionLabel.textColor = self.highlightTextColor
				} else {
					self.backgroundColor = .clear
                    self.optionLabel.textColor = self.normalTextColor
				}
			}
		}
		
		if animated {
			UIView.animate(withDuration: 0.3, animations: {
				executeSelection()
			})
		} else {
			executeSelection()
		}

		accessibilityTraits = selected ? .selected : .none
	}
	
}

#endif
