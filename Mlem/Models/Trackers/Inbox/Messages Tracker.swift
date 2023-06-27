//
//  Messages Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

@MainActor
class MessagesTracker: ObservableObject {
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var messages: [APIPrivateMessageView] = .init()
    // tracks the id of the 10th-from-last item so we know when to load more
    public var loadMarkId: Int = 0
    
    private var page: Int = 1
    
    func loadNextPage(account: SavedAccount) async throws {
        defer { isLoading = false }
        isLoading = true

        let newMessages = try await loadPage(account: account, page: page)

        guard !newMessages.isEmpty else {
            return
        }

        add(newMessages)
        page += 1
        loadMarkId = messages.count >= 40 ? messages[messages.count - 40].id : 0
    }
    
    func loadPage(account: SavedAccount, page: Int) async throws -> [APIPrivateMessageView] {
        let request = GetPrivateMessagesRequest(
            account: account,
            page: page,
            limit: 50
        )

        let response = try await APIClient().perform(request: request)

        return response.privateMessages
    }
    
    func add(_ newMessages: [APIPrivateMessageView]) {
        // let accepted = newMentions.filter { ids.insert($0.id).inserted }
        messages.append(contentsOf: newMessages)
    }
    
    func refresh(account: SavedAccount) async throws {
        let newMessages = try await loadPage(account: account, page: 1)
        messages = newMessages
        page = 1
    }
}
