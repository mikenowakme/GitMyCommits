//
//  ContentView.swift
//  GitMyCommits
//
//  Created by Mike Nowak on 12/10/20.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var commitFetcher = CommitResponseFetcher("mikenowakme", for: "GitMyCommits")
  
  var body: some View {
    NavigationView {
      List(commitFetcher.commits) { commitResponse in
        CommitResponseRow(commitResponse: commitResponse)
      }
      .navigationTitle("GetMyCommits")
      .alert(isPresented: $commitFetcher.errorOccurred) {
        Alert(title: Text("Hang on"),
              message: Text(errorMessage(error: commitFetcher.error, statusCode: commitFetcher.statusCode)),
              dismissButton: .default(Text("Ok")))
      }
    }
  }
  
  fileprivate func errorMessage(error: Error?, statusCode: Int?) -> String {
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

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct CommitResponseRow: View {
  let commitResponse: CommitResponse
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .center) {
        Text(commitResponse.commit.author.name)
          .font(.title2)
          .bold()
        Spacer()
        Text(commitResponse.commitHash)
          .font(.caption)
          .bold()
          .lineLimit(1)
      }
      
      Text(commitResponse.commit.message)
        .font(.callout)
      
      Spacer()
      
      HStack {
        Spacer()
        Text("\(commitResponse.commit.author.date)")
          .font(.caption2)
          .lineLimit(1)
      }
    }
  }
}
