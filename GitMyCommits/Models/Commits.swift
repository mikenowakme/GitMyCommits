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
//    curl -i https://api.github.com/repos/mikenowakme/GitMyCommits/commits

import Foundation


// These are Swift structs that model the parts of the response we need.

struct CommitResponse {
  let id: String
  let sha: String
  let commit: CommitInfo
  
  var commitHash: String {
    get {
      return sha.padding(toLength: 7, withPad: "", startingAt: 0)
    }
  }
}

struct CommitInfo {
  let author: PersonInfo
  let committer: PersonInfo
  let message: String
}

struct PersonInfo {
  let name: String
  let email: String
  let date: Date
}

struct Commit {
  let files: [FileInfo]
}

struct FileInfo {
  let id: String
  let filename: String
  let status: String
  let additions: Int
  let deletions: Int
  let changes: Int
}

// Decodadable extensions for JSONDecoder

// Often CodingKeys is used to transform json keys to more a swift friendly name
// In this case, there is a lot more data that comes back from GitHub than
// we need so we use CodingKeys to tell the JSONDecoder the values we are
// interested in.

extension PersonInfo: Decodable {
  enum CodingKeys: String, CodingKey {
    case name
    case email
    case date
  }
}

extension CommitInfo: Decodable {
  enum CodingKeys: String, CodingKey {
    case author
    case committer
    case message
  }
}

extension FileInfo: Decodable, Identifiable {
  enum CodingKeys: String, CodingKey {
    case id = "sha"  // this makes it Identifiable
    case filename
    case status
    case additions
    case deletions
    case changes
  }
}

extension Commit: Decodable {
  enum CodingKeys: String, CodingKey {
    case files
  }
}

extension CommitResponse: Decodable, Identifiable {
  enum CodingKeys: String, CodingKey {
    case id = "node_id"
    case sha
    case commit
  }
}

// Error code definition

enum CommitResponseError: LocalizedError {
  case unknownMimeType(mimeType: String?)
  
  var errorDescription: String? {
    get {
      switch self {
      case .unknownMimeType(let mimeType):
        if let mimeType = mimeType {
          return "Unknown mime type was returned: \(mimeType)"
        }
        else {
          return "Unknown mime type was return."
        }
      }
    }
  }
}
