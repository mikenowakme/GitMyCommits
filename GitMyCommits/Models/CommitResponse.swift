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
  let date: Date
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

struct CommitResponse: Decodable, Identifiable {
  let id: String
  let sha: String
  let commit: CommitInfo
  
  var commitHash: String {
    get {
      return sha.padding(toLength: 7, withPad: "", startingAt: 0)
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case id = "node_id"
    case sha
    case commit
  }
}

class CommitResponseFetcher: ObservableObject {
  let user: String
  let repository: String
  @Published var commits = [CommitResponse]()
  
  init(_ user: String, for repository: String) {
    self.user = user
    self.repository = repository
    
    fetch()
  }
  
  func fetch() {
    let url = URL(string: "https://api.github.com/repos/\(user)/\(repository)/commits")!
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let fetchedCommits = try decoder.decode([CommitResponse].self, from: data!)
        
        self.commits = fetchedCommits;
      }
      catch {
        print("Could not fetch", error)
      }
    }.resume()
  }
}
