import SwiftUI

struct LoginView: View {
    @State private var nickname = ""
    @State private var password = ""
    @Binding var isUserLoggedIn: Bool
    
    @EnvironmentObject var authenticationManager: AuthenticationManager

    var body: some View {
        VStack {
            TextField("nickname", text: $nickname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("login") {
                Task {
                    await authenticationManager.login(nickname: nickname, password: password)
                }
            }
            .font(.custom("KRSNA-DREAMER", size: 20))
            .padding()

            NavigationLink("register", destination: RegistrationView())
                .font(.custom("KRSNA-DREAMER", size: 20))
        }
        .padding()
    }

}


