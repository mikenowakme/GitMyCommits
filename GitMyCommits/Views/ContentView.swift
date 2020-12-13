//
//  ContentView.swift
//  GitMyCommits
//
//  Created by Mike Nowak on 12/10/20.
//

import SwiftUI

struct ContentView: View {
  var repoSettings: RepoSettings
  @State var showSettings = false

  @ObservedObject var commitFetcher = CommitResponseFetcher()
  
  var body: some View {
    NavigationView {
      List(commitFetcher.commits) { commitResponse in
        NavigationLink(
          destination: CommitDetailView(repoSettings: repoSettings, commitResponse: commitResponse),
          label: {
            CommitResponseRow(commitResponse: commitResponse)
          })
      }
      .navigationTitle(repoSettings.repository)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: refresh) {
              Label("Refresh", systemImage: "arrow.clockwise.circle")
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          NavigationLink("Settings", destination: RepositorySettingsView()
                          .environmentObject(repoSettings))
// This would enable the alert version
//          Button("Settings") {
//            showSettings = true
//          }
        }
      }
      .alert(isPresented: $commitFetcher.errorOccurred) {
        Alert(title: Text("Hang on"),
              message: Text(errorMessage(error: commitFetcher.error, statusCode: commitFetcher.statusCode)),
              dismissButton: .default(Text("Ok")))
      }
    }
    .sheet(isPresented: $showSettings) {
      RepositorySettingsView()
        .environmentObject(repoSettings)
    }
  }
  
  init(repoSettings: RepoSettings) {
    self.repoSettings = repoSettings
    
    commitFetcher.config(repoSettings: repoSettings)
  }
  
  func refresh() {
    commitFetcher.fetch()
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
    ContentView(repoSettings: RepoSettings())
  }
}

struct CommitResponseRow: View {
  let commitResponse: CommitResponse
  
  let formatter = DateFormatter()

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
      
      // Spacer()
      
      HStack {
        Spacer()
        Text("\(formatter.string(from: commitResponse.commit.author.date))")
          .font(.caption2)
          .lineLimit(1)
      }
    }
  }
  
  init(commitResponse: CommitResponse) {
    self.commitResponse = commitResponse
    
    formatter.dateStyle = .long
    formatter.timeStyle = .short
  }
}
