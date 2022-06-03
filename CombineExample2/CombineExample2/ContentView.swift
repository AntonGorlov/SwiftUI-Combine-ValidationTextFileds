//
//  ContentView.swift
//  CombineExample2
//
//  Created by Anton Gorlov on 03.06.2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var userViewModel = UserViewModel()
    
    var body: some View {
        
        Form {
            
            Section(footer: Text(userViewModel.userNameMessage).foregroundColor(.red)) {
                
                TextField("Name", text: $userViewModel.userName)
                    .autocapitalization(.none)
            }
            
            Section(footer: Text(userViewModel.passwordMessage).foregroundColor(.red)) {
                
                SecureField("Password", text: $userViewModel.password)
                
                SecureField("Password again", text: $userViewModel.passwordAgain)
            }
            
            Section {
                
                Button {
                    
                    userViewModel.isPresentAlert = true
                } label: {
                    
                    Text("Sign up")
                }
                .disabled(!userViewModel.isValid)
                
            }
        }
        .alert("Congratulations!",
               isPresented: $userViewModel.isPresentAlert) {
            
        } message: {
            
            Text("You are logged in")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
