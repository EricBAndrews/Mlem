//
//  Inbox Item View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-01.
//

import Foundation
import SwiftUI

struct InboxItemView: View {
    let repliesTracker: RepliesTracker
    let mentionsTracker: MentionsTracker
    let messagesTracker: MessagesTracker
    let account: SavedAccount
    let item: InboxItem
    
    var body: some View {
        switch item.type {
        case .reply(let reply):
            InboxReplyView(account: account, reply: reply, tracker: repliesTracker)
        case .mention(let mention):
            InboxMentionView(account: account, mention: mention, tracker: mentionsTracker)
        case .message(let message):
            InboxMessageView(account: account, message: message, tracker: messagesTracker)
        }
    }
}
