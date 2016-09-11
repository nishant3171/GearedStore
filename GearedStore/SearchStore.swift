//
//  SearchStore.swift
//  GearedStore
//
//  Created by Nishant Punia on 09/09/16.
//  Copyright © 2016 MLBNP. All rights reserved.
//

import UIKit

class SearchStore {
    var name = ""
    var artistName = ""
    var artworkURL60 = ""
    var artworkURL100 = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
}

func <(lhs: SearchStore,rhs: SearchStore) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .OrderedAscending
}
