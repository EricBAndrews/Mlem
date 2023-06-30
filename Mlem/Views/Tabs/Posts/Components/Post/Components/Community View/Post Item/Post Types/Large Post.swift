//
//  Large Post Preview.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import CachedAsyncImage
import SwiftUI

import Foundation

struct LargePost: View {
    // constants
    private let spacing: CGFloat = 10 // constant for readability, ease of modification

    // global state
    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var appState: AppState
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true

    // parameters
    let postView: APIPostView
    let account: SavedAccount
    let isExpanded: Bool
    let showPostCreator: Bool
    let showCommunity: Bool
    let voteOnPost: (ScoringOperation) async -> Void
    let savePost: (_ save: Bool) async throws -> Void
    let deletePost: () async -> Void

    // initializer--used so we can set showNsfwFilterToggle to false when expanded or true when not
    init(
        postView: APIPostView,
        account: SavedAccount,
        isExpanded: Bool,
        showPostCreator: Bool,
        showCommunity: Bool,
        voteOnPost: @escaping (ScoringOperation) async -> Void,
        savePost: @escaping (_ save: Bool) async throws -> Void,
        deletePost: @escaping () async -> Void
    ) {
        self.postView = postView
        self.account = account
        self.isExpanded = isExpanded
        self.showPostCreator = showPostCreator
        self.showCommunity = showCommunity
        self.voteOnPost = voteOnPost
        self.savePost = savePost
        self.deletePost = deletePost
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            // community name
            if showCommunity {
                CommunityLinkView(community: postView.community)
            }

            // post title
            Text("\(postView.post.name)\(postView.post.deleted ? " (Deleted)" : "")")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .italic(postView.post.deleted)

            // post body
            switch postView.postType {
            case .image(let url):
                CachedImageWithNsfwFilter(isNsfw: postView.post.nsfw, url: url)
                postBodyView
            case .link:
                WebsiteIconComplex(post: postView.post)
                postBodyView
            case .text(let postBody):
                // text posts need a little less space between title and body to look right, go figure
                postBodyView
                    .padding(.top, postBody.isEmpty ? nil : -2)
            case .titleOnly:
                EmptyView()
            }
            
            // post user
            if showPostCreator {
                UserProfileLink(account: account, user: postView.creator, showServerInstance: true)
            }

            PostInteractionBar(
                postView: postView,
                account: account,
                voteOnPost: voteOnPost,
                updatedSavePost: savePost,
                deletePost: deletePost
            )
        }
        .padding(.vertical, spacing)
        .padding(.horizontal, spacing)
    }

    // MARK: - Subviews
    
    @ViewBuilder
    var postBodyView: some View {
        if let bodyText = postView.post.body, !bodyText.isEmpty {
            if isExpanded {
                MarkdownView(text: bodyText, isNsfw: postView.post.nsfw)
                    .font(.subheadline)
            } else {
                MarkdownView(text: bodyText.components(separatedBy: .newlines).joined(separator: " "), isNsfw: postView.post.nsfw)
                    .lineLimit(8)
                    .font(.subheadline)
            }

        }
    }

}
