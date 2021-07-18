//
//  Card.swift
//  VK Tinder News Feed
//
//  Created by Alex Yatsenko on 18.07.2021.
//

import SwiftUI

struct Card: Identifiable {
  let id: UUID
  let imageName: String
  
  static let current = (1...3).map { Card(id: UUID(), imageName: "card\($0)") }
}
