//
//  Replies Feed View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

extension InboxView {
    @ViewBuilder
    func repliesFeedView() -> some View {
        Group {
            if repliesTracker.items.isEmpty {
                if repliesTracker.isLoading {
                    LoadingView(whatIsLoading: .replies)
                } else {
                    noRepliesView()
                }
            } else {
                LazyVStack(spacing: spacing) {
                    repliesListView()
                    
                    if repliesTracker.isLoading {
                        LoadingView(whatIsLoading: .replies)
                    } else {
                        // this isn't just cute--if it's not here we get weird bouncing behavior if we get here, load, and then there's nothing
                        Text("That's all!").foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func noRepliesView() -> some View {
        VStack(alignment: .center, spacing: 5) {
            Image(systemName: "text.bubble")
            
            Text("No replies to be found")
        }
        .padding()
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    func repliesListView() -> some View {
        ForEach(repliesTracker.items) { reply in
            VStack(spacing: spacing) {
                inboxReplyViewWithInteraction(account: account, reply: reply)
                
                Divider()
            }
        }
    }
    
    func inboxReplyViewWithInteraction(account: SavedAccount, reply: APICommentReplyView) -> some View {
        InboxReplyView(account: account, reply: reply)
            .task {
                if repliesTracker.shouldLoadContent(after: reply) {
                    await loadTrackerPage(tracker: repliesTracker)
                }
            }
            .contextMenu {
                ForEach(genCommentReplyMenuGroup(commentReply: reply)) { item in
                    Button {
                        item.callback()
                    } label: {
                        Label(item.text, systemImage: item.imageName)
                    }
                }
            }
            .padding(.horizontal)
    }
}
