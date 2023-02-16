//
//  ContentView.swift
//  StarsAndPlanetsClient
//
//  Created by Vid Tadel on 2/15/23.
//

import Apollo
import ComposableArchitecture
import SwiftUI
import StarsAndPlanetsApollo

struct ContentView: View {

  let client = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)

  @State var stars: [Star] = []
  var body: some View {
    List {
      ForEach(stars) { star in
        VStack(alignment: .leading) {
          Text(star.name)
            .font(.title2)
          Text("\(star.planets.count) planets" )
        }
      }
    }
    .onAppear {
      client.fetch(query: StarsQuery()) { result in
        switch result {
        case .success(let data):
//              dump(data.data?.stars.map { ($0.name, $0.planets) })
          guard let starsReply = data.data else {
            return
          }
          stars = starsReply.stars.map {
            .init(id: $0.id!,
                  name: $0.name,
                  planets: $0.planets.map { planet in
                .init(id: planet.id!, name: planet.name)
            })
          }
        case .failure(let error):
          print("failed: \(error)")
        }
      }
//          client.perform(mutation: NewStarMutation(name: "Sirius")) { result in
//            guard let data = try? result.get().data else {
//              print("failed")
//              return
//            }
//            print(data.createStar.id)
//          }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
