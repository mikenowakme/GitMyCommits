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
        List(commitFetcher.commits) { commit in
          VStack(alignment: .leading) {
            HStack(alignment: .center) {
              Text(commit.commit.author.name)
              .font(.title)
              Spacer()
              Text(commit.commitHash.padding(toLength: 7, withPad: "", startingAt: 0))
                .font(.caption)
                .bold()
                .lineLimit(1)
            }

            Text(commit.commit.message)
              .font(.callout)
            
            HStack {
              Spacer()
              Text(commit.commit.author.date)
                .font(.caption)
            }
          }
        }.navigationTitle("GetMyCommits")
      }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
