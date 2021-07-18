//
//  MainView.swift
//  VK Tinder News Feed
//
//  Created by Alex Yatsenko on 18.07.2021.
//

import SwiftUI

struct MainView: View {
  
  private enum DragState {
    case inactive
    case pressing
    case dragging(translation: CGSize)
    
    var translation: CGSize {
      switch self {
      case .inactive, .pressing:
        return .zero
      case .dragging(let translation):
        return translation
      }
    }
    
    var isDragging: Bool {
      switch self {
      case .inactive, .pressing:
        return false
      case .dragging:
        return true
      }
    }
    
    var isPressing: Bool {
      switch self {
      case .inactive:
        return false
      case .dragging, .pressing:
        return true
      }
    }
  }
  
  @GestureState private var dragState = DragState.inactive
  
  @State private var likeButtonPressed = false
  @State private var disLikeButtonPressed = false
  @State private var lastCardIndex = 1
  @State private var cardRemovalTransition = AnyTransition.trailingButton
  @State private var cardViews: [CardView] = {
    var views = [CardView]()
    for index in 0..<2 {
      views.append(CardView(card: Card.current[index]))
    }
    return views
  }()
  
  private let dragAreaThreshold: CGFloat = 65
  
  var body: some View {
    VStack(spacing: 40) {
      ZStack {
        ForEach(cardViews) { cardView in
          cardView
            .overlay((dragState.translation.width > dragAreaThreshold && isTopCard(card: cardView) || likeButtonPressed && isTopCard(card: cardView)) ? Color("red").opacity(0.2) : .clear)
            .overlay((dragState.translation.width < -dragAreaThreshold && isTopCard(card: cardView) || disLikeButtonPressed && isTopCard(card: cardView)) ? Color("blue").opacity(0.2) : .clear)
            .zIndex(isTopCard(card: cardView) ? 1 : 0)
            .overlay(
              ZStack {
                VStack {
                  HStack {
                    Spacer()
                    Text("Меньше таких   \nзаписей")
                      .foregroundColor(Color("blue"))
                    
                      .padding()
                      .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.white))
                      .padding(10)
                      .padding(.top, 70)
                    
                  }
                  Spacer()
                }.opacity((dragState.translation.width < -dragAreaThreshold && isTopCard(card: cardView) || disLikeButtonPressed && isTopCard(card: cardView)) ? 1 : 0)
                VStack {
                  HStack {
                    Text("Больше таких   \nзаписей")
                      .foregroundColor(Color("red"))
                      .padding()
                      .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.white))
                      .padding(10)
                      .padding(.top, 70)
                    Spacer()
                  }
                  Spacer()
                }.opacity((dragState.translation.width > dragAreaThreshold && isTopCard(card: cardView) || likeButtonPressed && isTopCard(card: cardView)) ? 1 : 0)
              }
            )
            .offset(x: isTopCard(card: cardView) ? dragState.translation.width : 0, y: isTopCard(card: cardView) ? dragState.translation.height: 0)
            .scaleEffect(dragState.isDragging && isTopCard(card: cardView) ? 0.85 : 1)
            .rotationEffect(Angle(degrees: isTopCard(card: cardView) ? Double(dragState.translation.width) / 12 : 0))
            .animation(.interpolatingSpring(stiffness: 120, damping: 120))
            .gesture(LongPressGesture(minimumDuration: 0.01)
                      .sequenced(before: DragGesture())
                      .updating(self.$dragState, body: { value, state, transaction in
                        switch value {
                        case .first(true):
                          state = .pressing
                        case .second(true, let drag):
                          state = .dragging(translation: drag?.translation ?? .zero)
                        default: break
                        }
                      })
                      .onChanged({ value in
                        guard case .second(true, let drag?) = value else { return }
                        if drag.translation.width < -dragAreaThreshold {
                          disLikeButtonPressed = true
                          cardRemovalTransition = .leadingButton
                        }
                        
                        if drag.translation.width > dragAreaThreshold {
                          likeButtonPressed = true
                          cardRemovalTransition = .trailingButton
                        }
                      })
                      .onEnded({ value in
                        guard case .second(true, let drag?) = value else { return }
                        disLikeButtonPressed = false
                        likeButtonPressed = false
                        if drag.translation.width < -dragAreaThreshold || drag.translation.width > dragAreaThreshold {
                          moveCards()
                        }
                      })).transition(cardRemovalTransition)
          
        }
      }.padding(.horizontal)
      HStack(spacing: 60) {
        Button(action: {}, label: {
          VStack(spacing: 20) {
            Image("dislike")
              .foregroundColor(disLikeButtonPressed ? .white: Color("red"))
              .padding(24)
              .background(Circle()
                            .foregroundColor(disLikeButtonPressed ? Color("blue"): .white))
              .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 0)
              .scaleEffect(disLikeButtonPressed ? 1.3 : 1)
            Text("Скрыть")
              .foregroundColor(Color("Text"))
          }.gesture(DragGesture(minimumDistance: 0.0)
                      .onChanged { _ in
                        cardRemovalTransition = .leadingButton
                        
                        disLikeButtonPressed = true }
                      .onEnded { _ in
                        moveCards()
                        disLikeButtonPressed = false })
        })
        Button(action: {}, label: {
          VStack(spacing: 20) {
            Image("like")
              .foregroundColor(likeButtonPressed ? .white: Color("blue"))
              .padding(24)
              .background(Circle()
                            .foregroundColor(likeButtonPressed ? Color("red"): .white))
              .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 0)
              .scaleEffect(likeButtonPressed ? 1.3 : 1)
            Text("Нравится")
              .foregroundColor(Color("Text"))
          }
          .gesture(DragGesture(minimumDistance: 0.0)
                              .onChanged { _ in
                                cardRemovalTransition = .trailingButton
                                likeButtonPressed = true }
                              .onEnded { _ in
                                moveCards()
                                likeButtonPressed = false })
        })
      }
    }
    .padding(.vertical)
  }
  
  private func isTopCard(card: CardView) -> Bool {
    guard let index = cardViews.firstIndex(where: { $0.id == card.id }) else { return false }
    return index == 0
  }
  
  private func moveCards() {
    cardViews.removeFirst()
    lastCardIndex += 1
    
    let cards = Card.current
    let card = cards[lastCardIndex % cards.count]
    let newCardView = CardView(card: card)
    cardViews.append(newCardView)
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
      .padding()
  }
}

