//
//  UserViewModel.swift
//  CombineExample2
//
//  Created by Anton Gorlov on 03.06.2022.
//

import Foundation
import Combine
import Navajo_Swift

class UserViewModel: ObservableObject {
    
    //Input
    
    @Published var userName      = ""
    @Published var password      = ""
    @Published var passwordAgain = ""
    
    //Output
    
    @Published var isValid = false
    @Published var userNameMessage = ""
    @Published var passwordMessage = ""
    @Published var isPresentAlert  = false
    
    private var cancellableBag = Set<AnyCancellable>()
    
    init() {
        
        setup()
    }
    
    // Subscribes
    private func setup() {
        
       isFormValidPublisher
            .receive(on: RunLoop.main) //  We can tell SwiftUI to execute this code on the UI thread
            .assign(to: \.isValid, on: self)
            .store(in: &cancellableBag)
        
        isUserNameValidPublisher
            .receive(on: RunLoop.main)
            .map { valid in
                
                valid ? "" : "UserName must at leat have 3 characters"
            }
            .assign(to: \.userNameMessage, on: self)
            .store(in: &cancellableBag)
        
        passwordStatusPublisher
            .receive(on: RunLoop.main)
            .map { passwordStatus -> String in
                
                    switch passwordStatus {
                        
                    case .empty:
                      return "Password must not be empty"
                        
                    case .noMatch:
                      return "Passwords don't match"
                        
                    case .notStrongEnough:
                      return "Password not strong enough"
                        
                    default:
                      return ""
                    }
            }
            .assign(to: \.passwordMessage, on: self)
            .store(in: &cancellableBag)
    }
    
    //MARK: - Publishers
    //MARK: Password publishers
    
    private var isPassowordEmptyPublisher: AnyPublisher<Bool, Never> {
        
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { password in
                
                return password == ""
            }
            .eraseToAnyPublisher()
    }
    
    private var arePasswordsEqualPublisher: AnyPublisher<Bool, Never> {
        
        Publishers.CombineLatest($password, $passwordAgain)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { password, passwordAgain in
                
                return password == passwordAgain
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordStrengthPublisher: AnyPublisher<PasswordStrength, Never> {
        
        $password
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { input in
                
                return Navajo.strength(ofPassword: input)
            }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordStrongEnoughPublisher: AnyPublisher<Bool, Never> {
        
        passwordStrengthPublisher
            .map { strength in
                
                switch strength {
                    
                case .reasonable, .strong, .veryStrong:
                    return true
                    
                default:
                    return false
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var passwordStatusPublisher: AnyPublisher<PasswordStatus, Never> {
        
        Publishers.CombineLatest3(isPassowordEmptyPublisher, arePasswordsEqualPublisher, isPasswordStrongEnoughPublisher)
            .map { passwordIsEmpty, passwordAreEqual, passwordIsStrongEnough in
                
                if passwordIsEmpty {
                    
                    return .empty
                }
                else if !passwordAreEqual {
                    
                    return .noMatch
                }
                else if !passwordIsStrongEnough {
                    
                    return .notStrongEnough
                }
                else {
                    
                    return .valid
                }
            }
            .eraseToAnyPublisher()
    }
    
    //MARK: Name publishers
    
    private var isUserNameValidPublisher: AnyPublisher<Bool, Never> {
        
        $userName
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { input in
                
                return input.count >= 3
            }
            .eraseToAnyPublisher()
    }
    
    //MARK: Final stage of the form validation
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        
        Publishers.CombineLatest(isUserNameValidPublisher, passwordStatusPublisher)
            .map { isValidName, passwordStatus in
                
                return isValidName && (passwordStatus == .valid)
            }
            .eraseToAnyPublisher()
    }
}
