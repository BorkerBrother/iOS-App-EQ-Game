import SwiftUI



struct QuestionTree: View {
    @StateObject var manager = QuizManager()
    @State private var isShowingAddCategory = false

    var body: some View {
        NavigationView {
            List(manager.categories) { categories in
                NavigationLink(destination: ContentView(courseIdentifier: "\(categories.id)")) {
                    HStack {
                        Image(systemName: "music.note.list")
                        Text(categories.name)
                    }
                }
            }
            .navigationTitle("Audio Kurse")
            .toolbar {
                Button("Kategorie hinzufügen") {
                    isShowingAddCategory = true
                }
            }
            .sheet(isPresented: $isShowingAddCategory) {
                AddCategoryView(manager: manager)
            }
        }
        .onAppear {
            Task {
                await manager.fetchCourses()
                await manager.fetchQuestions()
            }
        }
    }
}

struct QuestionTree_Previews: PreviewProvider {
    static var previews: some View {
        QuestionTree()
    }
}


// Ansicht zum Hinzufügen neuer Kategorien und Fragen
// Ansicht zum Hinzufügen neuer Kategorien und Fragen
struct AddCategoryView: View {
    @ObservedObject var manager: QuizManager
    @State private var categoryName = ""
    @State private var questions: [Question] = []

    var body: some View {
        NavigationView {
            VStack{
                Section(header: Text("Kategorie hinzufügen")) {
                    TextField("Kategorie Name", text: $categoryName)
                }

                Section(header: Text("Fragen hinzufügen")) {
                    ForEach(0..<questions.count, id: \.self) { index in
                        QuestionInputView(question: $questions[index])
                    }

                    Button("Frage hinzufügen") {
                        questions.append(Question(id: nil, created_at: "", title: "", answer: "", options: ["", "", "", ""], kategorie_id: nil))
                    }
                }

                Button("Speichern") {
                    Task {
                        await addCategoryAndQuestions()
                    }
                }
            }
            .navigationBarTitle("Neue Kategorie und Fragen", displayMode: .inline)
        }
    }

    private func addCategoryAndQuestions() {
        Task {
            do {
                // Kategorie hinzufügen
                await manager.addCategory(name: categoryName)
                // Fragen hinzufügen
                for question in questions {
                    try await manager.addQuestion(question)
                }
            } catch {
                print("Fehler beim Hinzufügen der Kategorie oder der Fragen: \(error)")
            }
        }
    }
}


struct QuestionInputView: View {
    @Binding var question: Question

    var body: some View {
        TextField("Frage eingeben", text: $question.title)
        TextField("Antwort eingeben", text: $question.answer)
        ForEach(0..<question.options.count, id: \.self) { index in
            TextField("Option \(index + 1)", text: $question.options[index])
        }
    }
}


