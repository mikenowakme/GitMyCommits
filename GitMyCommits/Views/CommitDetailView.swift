//
//  CommitDetailView.swift
//  GitMyCommits
//
//  Created by Mike Nowak on 12/13/20.
//

import SwiftUI

struct CommitDetailView: View {
  let repoSettings: RepoSettings
  let commitResponse: CommitResponse
  @ObservedObject var commitFetcher: CommitFetcher = CommitFetcher()
  
  var body: some View {
    VStack(alignment: .leading) {
      CommitResponseRow(commitResponse: commitResponse)
        .padding()
      Spacer()
      Form {
        Section(header: Label("Files", systemImage: "doc")) {
          List(commitFetcher.commit?.files ?? [FileInfo]()) {file in
            VStack(alignment: .leading) {
              Text(file.filename)
                .font(.title3)
              
              Text("Additions: \(file.additions), Deletions: \(file.deletions), Changes: \(file.changes)")
                .font(.caption)
            }
          }
        }
      }
      .onAppear {
        commitFetcher.config(repoSettings: repoSettings,
                             sha: commitResponse.sha)
      }
      .alert(isPresented: $commitFetcher.errorOccurred) {
        Alert(title: Text("Hang on"),
              message: Text(commitFetcher.errorMessage),
              dismissButton: .default(Text("Ok")))
      }
    }
  }
}

struct CommitDetailView_Previews: PreviewProvider {
  static var previews: some View {
    CommitDetailView(repoSettings: RepoSettings(),
                     commitResponse: CommitResponse(
                      id: "12345", sha: "9f44010d5613ca81004db9d2b10b14d72ef548a5",
                      commit: CommitInfo(
                        author: PersonInfo(
                          name: "Mike Nowak",
                          email: "mike@mikenowak.me",
                          date: Date()),
                        committer: PersonInfo(
                          name: "GitHub",
                          email: "github@github.com",
                          date: Date()),
                        message: "New Commit")))
  }
}
