//
//  Inbox Item Feed View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-01.
//

import Foundation
import SwiftUI

/**
 Generic type to render a feed of items.
 
 NOTE: buildItemView is responsible for:
 - interactions/context menus
 - on-the-fly loading
 */
struct InboxItemFeedView<T: Identifiable, V: View>: View {
    let account: SavedAccount
    var buildItemView: (SavedAccount, T) -> V
    let items: [T]
    // let isLoading: Bool
    
    var body: some View {
//        if items.isEmpty && !isLoading {
//            Text("Nothing to see here")
//                .foregroundColor(.secondary)
//        }
        LazyVStack(spacing: AppConstants.postAndCommentSpacing) {
            ForEach(items) { item in
                VStack(spacing: AppConstants.postAndCommentSpacing) {
                    buildItemView(account, item)
                        .padding(.horizontal)
                }
                
                Divider()
            }
            
//            if isLoading {
//                ProgressView()
//            }
        }
    }
}
