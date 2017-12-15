//
//  ViewController.swift
//  nfl-stats
//
//  Created by Pedro Henrique Pereira Lima on 24/11/17.
//  Copyright © 2017 Pedro Henrique Pereira Lima. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var searchResults = [SearchResult]()
    var hasSearched = false
	var isLoading = false
	let disposeBag = DisposeBag()

	struct Results {
		let songName: String
		let artistName: String
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
		tableView.rowHeight = 80
		tableView.tableFooterView = UIView()

		var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
		tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)

		cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
		tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)

		cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
		tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)

		searchBar.becomeFirstResponder()

		rxSetup()
    }

	func rxSetup() {
		let results = searchBar.rx.text.orEmpty
			.throttle(0.5, scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.flatMapLatest { query -> Observable<[SearchResult]> in
				if query.isEmpty {
					return .just([])
				}
				return ApiController.shared.search(search: query)
					.catchErrorJustReturn([])
			}
			.observeOn(MainScheduler.instance)

		results
			.bind(to: tableView.rx.items(cellIdentifier: TableViewCellIdentifiers.searchResultCell, cellType: SearchResultCell.self)) {
				(index, searchResult: SearchResult, cell) in
				cell.configure(for: searchResult)
			}
			.disposed(by: disposeBag)

	}
	
	// MARK:- Private Methods
	
	func showNetworkError() {
		let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store. Please try again.", preferredStyle: .alert)

		let action = UIAlertAction(title: "OK", style: .default, handler: nil)
		present(alert, animated: true, completion: nil)
		alert.addAction(action)
	}

	struct TableViewCellIdentifiers {
		static let searchResultCell = "SearchResultCell"
		static let nothingFoundCell = "NothingFoundCell"
		static let loadingCell = "LoadingCell"
	}
}

extension SearchViewController: UISearchBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isLoading {
			return 1
		} else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if isLoading {
			let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
			let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
			spinner.startAnimating()
			return cell
		} else
		if searchResults.count == 0 {
			return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
			let searchResult = searchResults[indexPath.row]

			cell.configure(for: searchResult)

			return cell
		}
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if searchResults.count == 0 || isLoading {
			return nil
		} else {
			return indexPath
		}
    }
}

