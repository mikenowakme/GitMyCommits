//
//  RepositorySettingsView.swift
//  GitMyCommits
//
//  Created by Mike Nowak on 12/12/20.
//

import SwiftUI

struct RepositorySettingsView: View {
  @EnvironmentObject var repoSettings: RepoSettings
  @Environment(\.presentationMode) var presentationMode
  
  @State private var account: String = "";
  @State private var repository: String = "";
  
  var body: some View {
    NavigationView {
      Form {
        TextField("Account", text: $account)
          .autocapitalization(.none)
          .disableAutocorrection(true)
        TextField("Respository", text: $repository)
          .autocapitalization(.none)
          .disableAutocorrection(true)
        
        HStack {
          Spacer()
          
          Button(action: {
            saveSettings()
            self.presentationMode.wrappedValue.dismiss()
          },
          label: {
            Text("Change")
          })
        }
      }
      .navigationBarTitle(Text("Change Repository"))
      .onAppear(perform: {
        account = repoSettings.account
        repository = repoSettings.repository
      })
    }
  }
  
  func saveSettings() {
    repoSettings.account = account
    repoSettings.repository = repository
  }
}

struct RepositorySettingsView_Previews: PreviewProvider {
  static var previews: some View {
    RepositorySettingsView()
      .environmentObject(RepoSettings())
  }
}
