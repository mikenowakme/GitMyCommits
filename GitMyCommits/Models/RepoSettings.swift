//
//  Settings.swift
//  GitMyCommits
//
//  Created by Mike Nowak on 12/12/20.
//

import Foundation

class RepoSettings: ObservableObject {
  @Published var account: String = "mikenowakme"
  @Published var repository: String = "GitMyCommits"
}
