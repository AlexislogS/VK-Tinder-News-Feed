//
//  AnyTransition+.swift
//  VK Tinder News Feed
//
//  Created by Alex Yatsenko on 18.07.2021.
//

import SwiftUI

extension AnyTransition {
  static var trailingButton: AnyTransition {
    AnyTransition.asymmetric(
      insertion: .identity,
      removal: .move(edge: .trailing).combined(with: .move(edge: .bottom))
    )
  }
  
  static var leadingButton: AnyTransition {
    AnyTransition.asymmetric(
      insertion: .identity,
      removal: .move(edge: .leading).combined(with: .move(edge: .bottom))
    )
  }
}
