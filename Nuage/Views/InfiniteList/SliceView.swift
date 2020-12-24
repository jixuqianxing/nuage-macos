//
//  SliceView.swift
//  Nuage
//
//  Created by Laurin Brandner on 03.12.20.
//  Copyright © 2020 Laurin Brandner. All rights reserved.
//

import Combine
import SwiftUI
import SoundCloud

private let subjectSubcription = -1
private let initialSliceSubscription = 0

struct SliceView<Element: Decodable&Identifiable, ContentView: View>: View {
    
    var elements: [Element] {
        return slices.map { $0.collection }
            .reduce([], +)
    }
    @State private var slices = [Slice<Element>]()
    
    private var subject = PassthroughSubject<Slice<Element>, Error>()
    private var publisher: AnyPublisher<Slice<Element>, Error>
    @State private var subscriptions = [Int: AnyCancellable]()
    
    private var content: ([Element], @escaping () -> ()) -> ContentView
    
    var body: some View {
        return content(elements, getNextSlice).onAppear {
            self.publisher.subscribe(subject)
                .store(in: &subscriptions, key: subjectSubcription)
            
            self.subject.receive(on: RunLoop.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { slice in
                    self.slices.append(slice)
                })
                .store(in: &self.subscriptions, key: initialSliceSubscription)
        }
    }
    
    init(publisher: AnyPublisher<Slice<Element>, Error>,
         @ViewBuilder content: @escaping ([Element], @escaping () -> ()) -> ContentView) {
        self.publisher = publisher
        self.content = content
    }
    
    private func getNextSlice() {
        guard subscriptions[self.elements.count] == nil else { return }
        
        let limit = (self.slices.last?.collection.count ?? initialSliceSubscription) * 2
        let currentSlicePublisher = slices.publisher
            .last()
            .mapError{ $0 as Error }
        
        subject.merge(with: currentSlicePublisher)
            .receive(on: RunLoop.main)
            .first()
            .flatMap { SoundCloud.shared.get(next: $0, limit: limit) }
            .sink(receiveCompletion: { _ in }, receiveValue: { slice in
                self.slices.append(slice)
            })
            .store(in: &subscriptions, key: self.elements.count)
    }
    
}