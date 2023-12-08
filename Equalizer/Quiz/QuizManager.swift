//
//  QuizManager.swift
//  LAUT
//
//  Created by Borker on 26.11.23.
//

import Foundation
import SwiftUI
import Supabase

class QuizManager: ObservableObject {
    
    @Published var questions = [Question]()
    @Published var categories = [Category]()
    
    
    let client = SupabaseClient(supabaseURL:
                                    URL(string: "https://duvyxgjyqvxylnxxhmqa.supabase.co")!,
                                supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1dnl4Z2p5cXZ4eWxueHhobXFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDA5ODkwOTAsImV4cCI6MjAxNjU2NTA5MH0.M4o8SDCOThCnDGWEgf_9B-OdZ4WkuZHusas__uawnyA")
    
    func addQuestion(_ question: Question) async throws {
        // Stellen Sie sicher, dass die Frage eine gültige ID hat, bevor Sie sie hinzufügen
        var questionData = question

        // Konvertieren Sie die Frage in ein JSON-Format, das in die Datenbank eingefügt werden kann
        let questionJSON = try JSONEncoder().encode(questionData)
        guard let questionDictionary = try JSONSerialization.jsonObject(with: questionJSON) as? [String: Any] else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Fehler beim Konvertieren der Frage in JSON"])
        }

        
        // Fügen Sie die Frage in die Datenbank ein
//        let response = try await client.database.from("Laut-Quiz").insert([questionDictionary]).execute()
//
//        // Überprüfen Sie die Antwort und handeln Sie entsprechend
//        guard response.error == nil else {
//            throw response.error!
//        }

        // Optional: Fragenliste aktualisieren
        await fetchQuestions()
    }
    
    func addCategory(name: String) async -> Int? {
        let newCategory = ["name": name]

        do {
            let response = try await client.database.from("categories")
                .insert(newCategory)
                .execute()

            // Verwenden Sie direkt response.data ohne optionale Bindung
            if let jsonArray = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]],
               let firstElement = jsonArray.first,
               let newCategoryId = firstElement["id"] as? Int {
                return newCategoryId
            }
        } catch {
            print("Fehler beim Speichern der Kategorie: \(error.localizedDescription)")
        }
        return nil
    }

    private func saveCategoryToDatabase(category: Category) async {
        do {
            var categoryData = category
            categoryData.id = nil // Entfernen der ID vor dem Speichern
            let response = try await client.database.from("categories").insert([categoryData]).execute()
            // Behandeln Sie hier die Antwort
        } catch {
            print("Fehler beim Speichern der Kategorie: \(error.localizedDescription)")
        }
    }
    
    func fetchCourses() async {
            do {
                let response = try await client.database.from("categories").select().execute()
                let fetchedCourses = try JSONDecoder().decode([Category].self, from: response.data)
                DispatchQueue.main.async {
                    self.categories = fetchedCourses
                }
            } catch {
                print("Fehler beim Abrufen der Kurse: \(error.localizedDescription)")
            }
        }
    
    func fetchQuestions() async {
        do {
            let response = try await client.database.from("Laut-Quiz").select().execute()
            let fetchedQuestions = try JSONDecoder().decode([Question].self, from: response.data)
            DispatchQueue.main.async {
                self.questions = fetchedQuestions
            }
        } catch {
            print("Fehler beim Abrufen der Fragen: \(error.localizedDescription)")
        }
    }

    func checkAnswerForCurrentQuestion(_ questionIndex: Int) -> Bool {
            guard questionIndex < questions.count else { return false }
            let question = questions[questionIndex]
            return question.selection == question.answer
        }

    
    func canSubmitQuiz() -> Bool {
        return questions.filter({$0.selection == nil }).isEmpty
    }
    
    func gradeQuiz() -> String {
        var correct: CGFloat = 0

        for question in questions {
            if question.answer == question.selection {
                correct += 1
            }
        }

        return "\((correct / CGFloat(questions.count)) * 100)%"
    }
    
}
