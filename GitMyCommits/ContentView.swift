//
//  ContentView.swift
//  GitMyCommits
//
//  Created by Mike Nowak on 12/10/20.
//

import SwiftUI

struct ContentView: View {
  var commitFetcher = CommitResponseFetcher("mikenowakme", for: "GitMyCommits")
  
    var body: some View {
      Text(commitFetcher.commits.debugDescription)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
