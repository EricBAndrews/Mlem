//
//  Inbox.swift
//  Mlem
//
//  Created by Jake Shirley on 6/25/23.
//

import Foundation
import SwiftUI
import CachedAsyncImage

// NOTE:
// all of the subordinate views are defined as functions in extensions because otherwise the tracker logic gets *ugly*
struct InboxView: View {
    let spacing: CGFloat = 10
    
    let account: SavedAccount
    @State var lastKnownAccountId: Int = 0 // id of the last account loaded with
    
    @State var allItems: [InboxItem] = .init()
    @StateObject var repliesTracker: RepliesTracker = .init()
    @StateObject var mentionsTracker: MentionsTracker = .init()
    @StateObject var messagesTracker: MessagesTracker = .init()
    
    @State var errorOccurred: Bool = false
    @State var errorMessage: String = ""
    
    @State private var selectionSection = 0
    
    @State private var navigationPath = NavigationPath()
    
    // computed
    @State var allItemsIsLoading: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            
            VStack(spacing: 10) {
                Picker(selection: $selectionSection, label: Text("Profile Section")) {
                    Text("All").tag(0)
                    Text("Replies").tag(1)
                    Text("Mentions").tag(2)
                    Text("Messages").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // These *all* have to get their *own* special little ScrollViews because:
                // - if they share one, it won't reset position to top on tab switch (even with ScrollViewReader, idk why)
                // - if I put it in Inbox Item Feed View, it can't get access to the error (unless I pass *that* in, too, at which point... why bother?
                // moreover, I can't just give them a tracker to bundle items and isLoading, because the all items view is based on an aggregation of trackers
                //
                // I hate it here
                //
                switch selectionSection {
                case 0:
                    ScrollView {
//                        if errorOccurred {
//                            errorView()
//                        } else {
                            InboxItemFeedView<InboxItem, InboxItemView>(account: account,
                                                                        buildItemView: buildInboxItem,
                                                                        items: allItems)
                                                                        // isLoading: allItemsIsLoading)
                        }
                   // }
                    .refreshable {
                        await refreshFeed(selectionSection: selectionSection)
                    }
                case 1:
                    ScrollView {
//                        if errorOccurred {
//                            errorView()
//                        } else {
                            InboxItemFeedView<APICommentReplyView, InboxReplyView>(account: account,
                                                                                   buildItemView: buildInboxReply,
                                                                                   items: repliesTracker.items)
                                                                                   // isLoading: repliesTracker.isLoading)
                        // }
                    }
                    .refreshable {
                        await refreshFeed(selectionSection: selectionSection)
                    }
                case 2:
                    ScrollView {
//                        if errorOccurred {
//                            errorView()
//                        } else {
                            InboxItemFeedView<APIPersonMentionView, InboxMentionView>(account: account,
                                                                                      buildItemView: buildInboxMention,
                                                                                      items: mentionsTracker.items)
                                                                                      // isLoading: mentionsTracker.isLoading)
//                        }
                    }
                    .refreshable {
                        await refreshFeed(selectionSection: selectionSection)
                    }
                case 3:
                    ScrollView {
//                        if errorOccurred {
//                            errorView()
//                        } else {
                            InboxItemFeedView<APIPrivateMessageView, InboxMessageView>(account: account,
                                                                                       buildItemView: buildInboxMessage,
                                                                                       items: messagesTracker.items)
                                                                                       // isLoading: messagesTracker.isLoading)
//                        }
                    }
                    .refreshable {
                        await refreshFeed(selectionSection: selectionSection)
                    }
                default:
                    Text("how did we get here?")
                }
            }
            
            Spacer()
        }
        // load trackers if empty or account changed
        .task(priority: .userInitiated) {
            print("performing initial load")
            if repliesTracker.items.isEmpty ||
                mentionsTracker.items.isEmpty ||
                messagesTracker.items.isEmpty ||
                lastKnownAccountId != account.id {
                await refreshFeed(selectionSection: 0)
                lastKnownAccountId = account.id
            }
        }
        .navigationTitle("Inbox")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(PlainListStyle())
        .handleLemmyViews(navigationPath: $navigationPath)
    }
    
    @ViewBuilder
    func errorView() -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.bubble")
                .font(.title)
            
            Text("Inbox loading failed!")
            
            Text(errorMessage)
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder func buildInboxItem(account: SavedAccount, item: InboxItem) -> InboxItemView {
        InboxItemView(repliesTracker: repliesTracker,
                      mentionsTracker: mentionsTracker,
                      messagesTracker: messagesTracker,
                      account: account,
                      item: item)
    }
    
    @ViewBuilder func buildInboxReply(account: SavedAccount, reply: APICommentReplyView) -> InboxReplyView {
        InboxReplyView(account: account, reply: reply, tracker: repliesTracker)
    }
    
    @ViewBuilder func buildInboxMention(account: SavedAccount, mention: APIPersonMentionView) -> InboxMentionView {
        InboxMentionView(account: account, mention: mention, tracker: mentionsTracker)
    }
    
    @ViewBuilder func buildInboxMessage(account: SavedAccount, message: APIPrivateMessageView) -> InboxMessageView {
        InboxMessageView(account: account, message: message, tracker: messagesTracker)
    }
}
