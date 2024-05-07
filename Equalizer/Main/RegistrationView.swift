import SwiftUI
import Supabase

struct RegistrationView: View {
    @State private var nickname = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            TextField("Nickname", text: $nickname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Passwort", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Registrieren") {
                Task {
//                    await register()
                }
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Registrierung"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }


}
