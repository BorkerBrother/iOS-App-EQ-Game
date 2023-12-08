import SwiftUI

struct ContentView: View {
    @StateObject var manager = QuizManager()
    @State private var showAnswerResult = false
    @State private var answerIsCorrect = false
    @State private var currentQuestionIndex = 0
    var courseIdentifier: String

    var body: some View {
        TabView(selection: $currentQuestionIndex) {
            ForEach(manager.questions.indices, id: \.self) { index in
                VStack {
                    Spacer()
                    QuestionView(question: $manager.questions[index])
                    Spacer()

                    Button {
                        answerIsCorrect = manager.checkAnswerForCurrentQuestion(currentQuestionIndex)
                            showAnswerResult = true
                        
                    } label: {
                        Text("Überprüfen")
                            .padding()
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color("AppColor"))
                                    .frame(width: 340)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(manager.questions[index].selection == nil)
                    .alert(isPresented: $showAnswerResult) {
                        Alert(title: Text(answerIsCorrect ? "Richtig!" : "Falsch"),
                              dismissButton: .default(Text("Nächste"), action: {
                                  moveToNextQuestion()
                              }))
                    }
                }
                .tag(index)
            }
        }
        .background(Color(.black))
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onAppear {
            Task {
                await manager.fetchQuestions()
            }
        }
    }

    private func moveToNextQuestion() {
        if currentQuestionIndex < manager.questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(courseIdentifier: "equalizer")
    }
}

