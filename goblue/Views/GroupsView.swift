//
//  GroupsView.swift
//  goblue
//
//  Created by Joshua Riley on 10/02/2025.
//

import SwiftUI

struct GroupsView: View {
    
    @State var searchText: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                List {
                    ForEach(0..<10) { index in
                        NavigationLink(destination: Text("Group \(index + 1) Details")) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("Group \(index + 1)")
                                        .font(.headline)
                                    Text("\(Int.random(in: 2...15)) members")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }.navigationTitle("Groups").searchable(text: $searchText)
        }
    }
}

#Preview {
    GroupsView()
}
