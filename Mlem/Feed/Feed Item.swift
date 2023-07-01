//
//  File.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-01.
//

import Foundation
import SwiftUI

protocol FeedItem {
    associatedtype V: View
    func buildView() -> V
}
