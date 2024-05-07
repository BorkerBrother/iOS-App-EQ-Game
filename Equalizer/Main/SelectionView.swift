//
//  MainView.swift
//  Equalizer
//
//  Created by Borker on 30.11.23.
//


import SwiftUI
import Foundation

struct SelectionView: View {
    @Binding var selectedTab: Int

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Hintergrund auf die gesamte View ausdehnen

            VStack {
                HStack {
                    VStack {
                        Text("ears")
                            .font(.custom("KRSNA-DREAMER", size: 30))
                            .foregroundColor(.white)
                        

                        Image("Laut_SocialMedia_Totd")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                            .onTapGesture {
                                selectedTab = 0
                            }
                    }

                    VStack {
                        Text("quiz")
                            .font(.custom("KRSNA-DREAMER", size: 30))
                            .foregroundColor(.white)

                        Image("Laut_SocialMedia_Quiz")
                            .resizable()
                            .cornerRadius(8)
                            .aspectRatio(contentMode: .fit)
                            .onTapGesture {
                                selectedTab = 2
                            }
                    }
                }
                .padding()
            }
        }
    }
}

