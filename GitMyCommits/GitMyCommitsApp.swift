//
//  GitMyCommitsApp.swift
//  GitMyCommits
//
//  Created by Mike Nowak on 12/10/20.
//

import SwiftUI

@main
struct GitMyCommitsApp: App {
  @StateObject var repoSettings = RepoSettings()
  
    var body: some Scene {
        WindowGroup {
          ContentView(repoSettings: repoSettings)
        }
    }
}
