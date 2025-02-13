//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziAccount
import SwiftUI

/// Displays the user's profile information from their questionnaire responses.
struct ProfileView: View {
    @Environment(Account.self) private var account: Account?
    @State private var isEditing = false
    
    // Hardcoded profile data with @State to enable editing
    @State private var name = "Annie Jones"
    @State private var sleepWithPhone = true
    @State private var sleepTime = "10:30 PM"
    @State private var sleepDuration = "8"
    @State private var nightCoughing = "Sometimes"
    @State private var respiratoryConditions = "Allergies"
    @State private var smokeExposure = "No"
    
    @Binding var presentingAccount: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Section("Personal Information") {
                    if isEditing {
                        TextField("Name", text: $name)
                    } else {
                        ProfileRow(title: "Name", value: name)
                    }
                }
                
                Section("Sleep Information") {
                    if isEditing {
                        Toggle("Phone Nearby While Sleeping", isOn: $sleepWithPhone)
                        HStack {
                            Text("Sleep Time")
                            Spacer()
                            TextField("Time", text: $sleepTime)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Hours of Sleep")
                            Spacer()
                            TextField("Hours", text: $sleepDuration)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                    } else {
                        ProfileRow(title: "Phone Nearby While Sleeping", value: sleepWithPhone ? "Yes" : "No")
                        ProfileRow(title: "Sleep Time", value: sleepTime)
                        ProfileRow(title: "Hours of Sleep", value: "\(sleepDuration) hours")
                    }
                }
                
                Section("Health Information") {
                    if isEditing {
                        Picker("Night Coughing", selection: $nightCoughing) {
                            Text("Yes").tag("Yes")
                            Text("No").tag("No")
                            Text("Sometimes").tag("Sometimes")
                        }
                        Picker("Respiratory Conditions", selection: $respiratoryConditions) {
                            Text("None").tag("None")
                            Text("Asthma").tag("Asthma")
                            Text("COPD").tag("COPD")
                            Text("Allergies").tag("Allergies")
                        }
                        Picker("Smoke Exposure", selection: $smokeExposure) {
                            Text("Yes").tag("Yes")
                            Text("No").tag("No")
                            Text("Sometimes").tag("Sometimes")
                        }
                    } else {
                        ProfileRow(title: "Night Coughing", value: nightCoughing)
                        ProfileRow(title: "Respiratory Conditions", value: respiratoryConditions)
                        ProfileRow(title: "Smoke Exposure", value: smokeExposure)
                    }
                }
            }
            .navigationTitle("My Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                }
                if account != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
            }
        }
    }
}

struct ProfileRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 2)
    }
}

#if DEBUG
#Preview {
    ProfileView(presentingAccount: .constant(false))
        .environment(Account())
}
#endif
