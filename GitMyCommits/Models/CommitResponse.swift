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

struct FileInfo {
  let id: String
  let filename: String
  let status: String
  let additions: Int
  let deletions: Int
  let changes: Int
}

extension FileInfo: Decodable, Identifiable {
  enum CodingKeys: String, CodingKey {
    case id = "sha"
    case filename
    case status
    case additions
    case deletions
    case changes
  }
}

struct Commit {
  let files: [FileInfo]
}

extension Commit: Decodable {
  enum CodingKeys: String, CodingKey {
    case files
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

class CommitResponseFetcher: ObservableObject {
  var repoSettings: RepoSettings? = nil
  
  @Published var commits = [CommitResponse]()
  @Published var errorOccurred: Bool = false
  @Published var error: Error? = nil
  @Published var statusCode: Int? = nil
  
  func config(repoSettings: RepoSettings) {
    self.repoSettings = repoSettings
    
    fetch()
  }
  
  func fetch() {
    guard let repoSettings = repoSettings else { return }
    let url = URL(string: "https://api.github.com/repos/\(repoSettings.account)/\(repoSettings.repository)/commits")!
    self.errorOccurred = false
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      
      // error checking
      if let error = error {
        DispatchQueue.main.async {
          self.errorOccurred = true
          self.error = error
        }
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
        let httpResponse = response as? HTTPURLResponse
        DispatchQueue.main.async {
          self.errorOccurred = true
          self.statusCode = httpResponse?.statusCode
        }
        return
      }
      
      // Make sure we got a JSON response and we have data
      if let mimeType = httpResponse.mimeType, mimeType == "application/json",
         let data = data {
        do {
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .iso8601
          
          let fetchedCommits = try decoder.decode([CommitResponse].self, from: data)
          
          DispatchQueue.main.async {
            self.commits = fetchedCommits;
          }
        }
        catch {
          print("Could not fetch", error)
        }
      }
      else {
        DispatchQueue.main.async {
          self.errorOccurred = true
          self.error = CommitResponseError.unknownMimeType(mimeType: httpResponse.mimeType)
        }
      }
    }.resume()
  }
  
  var errorMessage: String {
    get {
      var errorMessage = "An error occured while fetching the git commits for this repository."
      
      if let error = error {
        errorMessage.append(" Error: \(error.localizedDescription)")
      }
      
      if let statusCode = statusCode {
        errorMessage.append(" Status code: \(statusCode)")
      }
      
      return errorMessage
    }
  }
}

class CommitFetcher: ObservableObject {
  var repoSettings: RepoSettings?
  var sha: String?
  
  @Published var commit: Commit?
  @Published var errorOccurred: Bool = false
  @Published var error: Error? = nil
  @Published var statusCode: Int? = nil
  
  func config(repoSettings: RepoSettings, sha: String) {
    self.repoSettings = repoSettings
    self.sha = sha
    
    fetch()
  }
  
  func fetch() {
    guard let repoSettings = repoSettings, let sha = sha else { return }
    let url = URL(string: "https://api.github.com/repos/\(repoSettings.account)/\(repoSettings.repository)/commits/\(sha)")!
    self.errorOccurred = false
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      
      // error checking
      if let error = error {
        DispatchQueue.main.async {
          self.errorOccurred = true
          self.error = error
        }
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
        let httpResponse = response as? HTTPURLResponse
        DispatchQueue.main.async {
          self.errorOccurred = true
          self.statusCode = httpResponse?.statusCode
        }
        return
      }
      
      // Make sure we got a JSON response and we have data
      if let mimeType = httpResponse.mimeType, mimeType == "application/json",
         let data = data {
        do {
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .iso8601
          
          let fetchedCommit = try decoder.decode(Commit.self, from: data)
          
          DispatchQueue.main.async {
            self.commit = fetchedCommit;
          }
        }
        catch {
          print("Could not fetch", error)
        }
      }
      else {
        DispatchQueue.main.async {
          self.errorOccurred = true
          self.error = CommitResponseError.unknownMimeType(mimeType: httpResponse.mimeType)
        }
      }
    }.resume()
  }
  
  var errorMessage: String {
    get {
      var errorMessage = "An error occured while fetching the details for this commit."
      
      if let error = error {
        errorMessage.append(" Error: \(error.localizedDescription)")
      }
      
      if let statusCode = statusCode {
        errorMessage.append(" Status code: \(statusCode)")
      }
      
      return errorMessage
    }
  }
}
