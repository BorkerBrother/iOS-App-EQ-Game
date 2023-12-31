//
//  authenticationManager.swift
//  MAIN_LAUT
//
//  Created by Borker on 16.12.23.
//

import Foundation
import SwiftUI
import Supabase
import KeychainSwift

let keychain = KeychainSwift()

func saveCredentials(nickname: String, password: String) {
    keychain.set(nickname, forKey: "userNickname")
    keychain.set(password, forKey: "userPassword")
}

func loadCredentials() -> (nickname: String?, password: String?) {
    let nickname = keychain.get("userNickname")
    let password = keychain.get("userPassword")
    return (nickname, password)
}

func loadname() -> (String?) {
    let nickname = keychain.get("userNickname")
    return (nickname)
}

enum NavigationTarget {
    case selectionView
    case registrationView
}



struct User: Codable, Hashable {
    var id: Int?
    var nickname: String?
    var password: String?
    let created_at: String?
    var score: Int
}

class AuthenticationManager: ObservableObject {
    private let client: SupabaseClient
    private let keychain = KeychainSwift()

    @Published var isUserLoggedIn: Bool = false
    @Published var userScore: Int = 0
    @Published var currentUserNickname: String?
   

    init() {
        client = SupabaseClient(supabaseURL: URL(string: "https://duvyxgjyqvxylnxxhmqa.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1dnl4Z2p5cXZ4eWxueHhobXFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDA5ODkwOTAsImV4cCI6MjAxNjU2NTA5MH0.M4o8SDCOThCnDGWEgf_9B-OdZ4WkuZHusas__uawnyA")
    }

    func login(nickname: String, password: String) async {
        do {
            let response = try await client.database.from("Users")
                .select()
                .execute()

            let users = try JSONDecoder().decode([User].self, from: response.data)

            if let user = users.first, user.password == password {
                print("Erfolgreich angemeldet: \(String(describing: user.nickname))")
                DispatchQueue.main.async {
                                    self.isUserLoggedIn = true
                                    self.currentUserNickname = user.nickname
                                    self.userScore = user.score
                                    }
                saveCredentials(nickname: nickname, password: password)
            } else {
                print("Falscher Benutzername oder Passwort")
            }
        } catch {
            print("Fehler bei der Anmeldung: \(error.localizedDescription)")
        }
    }

    func register(nickname: String, password: String) async {
        // Implementieren Sie die Registrierungslogik
    }

    private func saveCredentials(nickname: String, password: String) {
        keychain.set(nickname, forKey: "userNickname")
        keychain.set(password, forKey: "userPassword")
    }

    func loadCredentials() -> (nickname: String?, password: String?) {
            let nickname = keychain.get("userNickname")
            let password = keychain.get("userPassword")
            return (nickname, password)
        }

    func logout() {
        isUserLoggedIn = false
        keychain.delete("userNickname")
        keychain.delete("userPassword")
    }
    

    func updateScoreIfHigher(nickname: String, newScore: Int) async {
        do {
            // Fetch the current user's data
            let userResponse = try await client.database.from("Users")
                .select()
                .eq("nickname", value: nickname)
                .execute()

            if !userResponse.data.isEmpty {
                
                let users = try JSONDecoder().decode([User].self, from: userResponse.data)
                if let currentUser = users.first {
                    // Check if the new score is higher than the current score
                    if newScore > currentUser.score {
                        // Update the score in the database
                        let updateResponse = try await client.database.from("Users")
                            .update(["score": newScore])
                            .eq("nickname", value: nickname)
                            .execute()

                        if !updateResponse.data.isEmpty {
                            DispatchQueue.main.async {
                                self.userScore = newScore
                                print("test" ,(self.userScore))
                            }
                        } else {
                            print("Fehler beim Aktualisieren des Scores: ")
                        }
                    } else {
                        print("Neuer Score ist nicht höher als der aktuelle Score.")
                    }
                } else {
                    print("Benutzer nicht gefunden.")
                }
            } else {
                print("Fehler beim Abrufen des Benutzer-Scores: ")
            }
        } catch {
            print("Fehler beim Aktualisieren des Scores: \(error.localizedDescription)")
        }
    }
    
    // In AuthenticationManager
    func fetchCurrentScore(nickname: String) async -> Int {
        do {
            let response = try await client.database.from("Users")
                .select("score")
                .eq("nickname", value: nickname)
                .execute()

            let data = response.data
            let users = try JSONDecoder().decode([User].self, from: data)

            if let user = users.first {
                DispatchQueue.main.async {
                    self.userScore = user.score
                }
                return user.score
                
            } else {
                print("Benutzer nicht gefunden.")
                print("Fetching score for nickname: \(nickname)")
                return 0
            }
        } catch {
            print("Fehler beim Abrufen des aktuellen Scores: \(error)")
            return 0
        }
    }

    
    
    func fetchLeaderboard() async -> [User] {
        do {
            let response = try await client.database.from("Users")
                .select()
                .order("score", ascending: false)
                .execute()

            let users = try JSONDecoder().decode([User].self, from: response.data)
            return users
        } catch {
            print("Fehler beim Abrufen der Bestenliste: \(error.localizedDescription)")
            return []
        }
    }
  
}
