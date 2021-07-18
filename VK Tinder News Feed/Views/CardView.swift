//
//  CardView.swift
//  VK Tinder News Feed
//
//  Created by Alex Yatsenko on 18.07.2021.
//

import SwiftUI

struct CardView: View, Identifiable {
  
  let id = UUID()
  let card: Card
  
  var body: some View {
    Image(card.imageName)
      .resizable()
      .cornerRadius(16)
      .scaledToFit()
      .frame(minWidth: 0, maxWidth: .infinity)
  }
}

struct CardView_Previews: PreviewProvider {
  static var previews: some View {
    CardView(card: Card(id: UUID(), imageName: "card1"))
      .previewLayout(.fixed(width: 335, height: 447))
  }
}
