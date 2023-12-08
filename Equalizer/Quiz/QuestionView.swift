//
//  QuestionView.swift
//  LAUT
//
//  Created by Borker on 23.11.23.
//

import SwiftUI
import Foundation

struct Category: Encodable, Decodable, Identifiable, Hashable {
    var id: Int?
    let name: String
    // Weitere Eigenschaften nach Bedarf...
}

struct Question : Encodable, Decodable, Identifiable, Hashable {
    let id: Int?
    let created_at: String
    var title: String
    var answer: String
    var options: [String]
    var selection: String?
    var kategorie_id: Int?
}


struct QuestionView: View {
    @Binding var question: Question
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question.title)

            ForEach(question.options, id: \.self) { option in
                HStack {
                    Button {
                        question.selection = option
                    } label: {
                        if question.selection == option {
                            Circle()
                                .shadow(radius: 3)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue) // Change the selected color
                        } else {
                            Circle()
                                .stroke()
                                .shadow(radius: 3)
                                .frame(width: 24, height: 24)
                        }
                    }

                    Text(option)
                        .foregroundColor(.white)
                }
            }
        }
        .foregroundColor(Color(uiColor: .white))
        .padding(.horizontal, 20)
        .frame(width: 330, height: 550, alignment: .leading)
        .background(Color(uiColor: .gray))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}


struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView(question: .constant(Question(id: 1, created_at: "test", title: "Sample Question", answer: "A", options: ["A", "B", "C", "D"], selection: "A", kategorie_id: 1)))
    }
}
