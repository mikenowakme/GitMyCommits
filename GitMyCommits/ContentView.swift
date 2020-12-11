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
      List(commitFetcher.commits) { commit in
        VStack(alignment: .leading) {
          Text(commit.commit.author.name)
            .font(.title)
          Text(commit.commit.committer.date)
            .font(.caption)
          Text(commit.commit.message)
            .font(.callout)
        }
      }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
