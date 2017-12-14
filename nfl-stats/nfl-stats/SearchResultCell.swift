//
//  SearchResultCell.swift
//  nfl-stats
//
//  Created by Pedro Henrique Pereira Lima on 13/12/17.
//  Copyright © 2017 Pedro Henrique Pereira Lima. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
	@IBOutlet weak var playerImage: UIImageView!
	@IBOutlet weak var firstNameLabel: UILabel!
	@IBOutlet weak var lastNameLabel: UILabel!

	var downloadTask: URLSessionDownloadTask?
	
    override func awakeFromNib() {
        super.awakeFromNib()
		let selectedView = UIView(frame: CGRect.zero)
		selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
		selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	// MARK:- Public Methods
	func configure(for result: SearchResult) {
		firstNameLabel.text = result.name
		if result.artistName.isEmpty {
			lastNameLabel.text = "Unknown"
		} else {
			lastNameLabel.text = String(format: "%@ (%@)", result.artistName)
		}

		playerImage.image = UIImage(named: "Placeholder")

		if let smallURL = URL(string: result.imageSmall) {
			downloadTask = playerImage.loadImage(url: smallURL)
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		downloadTask?.cancel()
		downloadTask = nil
	}

}
