//
//  LoginScreen.swift
//  MarvelHeros
//
//  Created by Sravan on 20/07/2025.
//

import SwiftUI

struct LoginScreen: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @State private var isShowingAlert: Bool = false
    @State private var loginMessage: String = ""
    
    var body: some View {
        ZStack {
            Color.gray
            loginCard
                .frame(maxHeight: 450)
        }
    }
    
    var loginCard: some View {
        ZStack {
            Color.white
            
            if loginViewModel.loadingState == .loading {
                spinnerView
            } else {
                VStack {
                    logoView
                    loginView
                }
            }
        }
        .cornerRadius(25)
        .padding()
    }
    
    var spinnerView: some View {
        ProgressView("Loading...")
            .font(.title)
            .foregroundStyle(.gray)
    }
    
    var logoView: some View {
        Image(systemName: "checkmark")
            .font(.title)
            .frame(width: 45, height: 45)
            .background(.green)
            .foregroundStyle(.white)
            .cornerRadius(50)
    }
    
    var loginView: some View {
        VStack {
            userNameTextField
            passwordTextField
            loginButton
        }
        .alert("Login Status", isPresented: $isShowingAlert, actions: {
            Button("OK") {
                
            }
        }, message: {
            Text(loginMessage)
        })
    }
    
    private var userNameTextField: some View {
        TextField("Enter username", text: $loginViewModel.userName)
            .padding()
            .border(Color.gray, width: 1)
            .cornerRadius(5)
            .padding()
    }
    
    private var passwordTextField: some View {
        SecureField("Enter password", text: $loginViewModel.userPassword)
            .padding()
            .border(Color.gray, width: 1)
            .cornerRadius(5)
            .padding()
    }
    
    private var loginButton: some View {
        Button("Login") {
            validateLogin()
        }
        
    }
    
    private func validateLogin() {
        Task {
            let result = await loginViewModel.validateLogin()
            loginMessage = result ? "Success" : "Failed"
            isShowingAlert.toggle()
        }
    }
}

public enum LoadingState: Equatable {
    case idle, loading, loaded, error(String)
}

class LoginViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var userPassword: String = ""
    @Published var loadingState: LoadingState = .idle
    
    func validateLogin() async -> Bool {
        loadingState = .loading
        do {
            try await Task.sleep(for: .seconds(3))
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
            return false
        }
        return (userName == "Sravan" && userPassword == "Sravan")
    }
}

#Preview {
    LoginScreen(loginViewModel: LoginViewModel())
}
