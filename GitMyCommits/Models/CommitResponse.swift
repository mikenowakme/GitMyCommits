//
//  CommitResponse.swift
//  GitMyCommits
//
//  Created by Mike Nowak on 12/10/20.
//

// These classes will model the data we receive from the GitHub API
// The URL for commits is:
//    https://api.github.com/users/{user}/{repository}/commits

// You can get a sample like this:
//    curl -i https://api.github.com/users/mikenowakme/GitMyCommits/commits

import Foundation

// These are Swift structs that model the parts of the response we need.

// Often CodingKeys is used to transform json keys to more a swift friendly name
// In this case, there is a lot more data that comes back from GitHub than
// we need so we use CodingKeys to tell the JSONDecoder the values we are
// interested in.

struct PersonInfo {
  let name: String
  let email: String
  let date: String
}

extension PersonInfo: Decodable {
  enum CodingKeys: String, CodingKey {
    case name
    case email
    case date
  }
}

struct CommitInfo {
  let author: PersonInfo
  let committer: PersonInfo
  let message: String
}

extension CommitInfo: Decodable {
  enum CodingKeys: String, CodingKey {
    case author
    case committer
    case message
  }
}

struct CommitResponse: Decodable {
  let node_id: String
  let commit: CommitInfo
  
  enum CodingKeys: String, CodingKey {
    case node_id
    case commit
  }
}
