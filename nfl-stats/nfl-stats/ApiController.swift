//
//  ApiController.swift
//  nfl-stats
//
//  Created by Pedro Henrique Pereira Lima on 14/12/17.
//  Copyright © 2017 Pedro Henrique Pereira Lima. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ApiController {
	static var shared = ApiController()
	var dataTask: URLSessionDataTask?

	/// The URL string
	func iTunesURL(searchText: String) -> URL {
		let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
		let urlString = String(format:"https://itunes.apple.com/search?term=%@", encodedText)
		let url = URL(string: urlString)
		return url!
	}

	//MARK: - API Calls
	func iTunesSearch(search term: String) -> Observable<Results> {
		return Observable.just(Results(songName: "Bat Country", artistName: "Avenged Sevenfold"))
	}

	func parse(data: Data) -> [SearchResult] {
		do {
			let decoder = JSONDecoder()
			let result = try decoder.decode(ResultArray.self, from:data)
			return result.results
		} catch {
			print("JSON Error: \(error)")
			return []
		}
	}

	/// Make API request
	func search(search term: String) -> Observable<[SearchResult]> {
		let url = iTunesURL(searchText: term)
		let request = URLRequest(url: url)
		let session = URLSession.shared

		return session.rx.data(request: request).map { self.parse(data: $0) }
	}

	struct Results {
		let songName: String
		let artistName: String
	}
}
