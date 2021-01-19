//
//  CommitFetcher.swift
//  GitMyCommits
//
//  Created by Mike Nowak on 1/18/21.
//

import Foundation

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
