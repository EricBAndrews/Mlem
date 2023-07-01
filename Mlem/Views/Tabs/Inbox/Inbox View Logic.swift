//
//  Inbox Feed View Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

extension InboxView {
    func refreshFeed(selectionSection: Int) async {
        do {
            print(selectionSection)
//            defer { allItemsIsLoading = false }
//            if selectionSection == 0 {
//                allItemsIsLoading = true
//            }
            // only refresh visible feed
            if selectionSection == 0 || selectionSection == 1 {
                try await repliesTracker.refresh(account: account)
            }
            if selectionSection == 0 || selectionSection == 2 {
                try await mentionsTracker.refresh(account: account)
            }
            if selectionSection == 0 || selectionSection == 3 {
                try await messagesTracker.refresh(account: account)
            }
            
            // only aggregate when 0
            if selectionSection == 0 {
                aggregateTrackers()
            }
//            
//            errorOccurred = false
        } catch APIClientError.networking {
            errorOccurred = true
            errorMessage = "Network error occurred, check your internet and retry"
        } catch APIClientError.response(let message, _) {
            print(message)
            errorOccurred = true
            errorMessage = "API error occurred, try refreshing"
        } catch APIClientError.cancelled {
            print("Failed while loading feed (request cancelled)")
            errorOccurred = true
            errorMessage = "Request was cancelled, try refreshing"
        } catch let message {
            print(message)
            errorOccurred = true
            errorMessage = "A decoding error occurred, try refreshing."
        }
    }
    
    func aggregateTrackers() {
        let mentions = mentionsTracker.items.map { item in
            InboxItem(published: item.personMention.published, id: item.id, type: .mention(item))
        }
        
        let messages = messagesTracker.items.map { item in
            InboxItem(published: item.privateMessage.published, id: item.id, type: .message(item))
        }
        
        let replies = repliesTracker.items.map { item in
            InboxItem(published: item.commentReply.published, id: item.id, type: .reply(item))
        }
        
        allItems = merge(arr1: mentions, arr2: messages, compare: wasPostedAfter)
        allItems = merge(arr1: allItems, arr2: replies, compare: wasPostedAfter)
    }

    /**
     returns true if lhs was posted after rhs
     */
    func wasPostedAfter(lhs: InboxItem, rhs: InboxItem) -> Bool {
        return lhs.published > rhs.published
    }
}
