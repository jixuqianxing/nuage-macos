//
//  UserGrid.swift
//  Nuage
//
//  Created by Laurin Brandner on 27.12.19.
//  Copyright © 2019 Laurin Brandner. All rights reserved.
//

import SwiftUI
import Combine
import SoundCloud
import StackNavigationView

struct UserGrid<Element: Decodable&Identifiable&Filterable>: View {
    
    var publisher: InfinitePublisher<Element>
    private var transform: (Element) -> User
    
    var body: some View {
        InfiniteGrid(publisher: publisher) { users, idx -> AnyView in
            let user = transform(users[idx])
            AnyView(StackNavigationLink(destination: UserView(user: user)) {
                UserRow(user: user)
            })
        }
    }
    
}

extension UserGrid where Element == User {
    
    init(for publisher: AnyPublisher<Slice<User>, Error>) {
        self.init(publisher: .slice(publisher)) { $0 }
    }
    
}

extension UserGrid where Element == Recommendation {
    
    init(for publisher: AnyPublisher<Slice<Recommendation>, Error>) {
        self.init(publisher: .slice(publisher)) { $0.user }
    }
    
}


struct UserRow: View {
    
    var user: User
    
    var body: some View {
        HStack {
            RemoteImage(url: user.avatarURL, cornerRadius: 25)
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(user.username)
                    .bold()
                    .lineLimit(1)
                Text(String(user.followerCount ?? 0))
            }
        }
    }

}

//struct UserList_Previews: PreviewProvider {
//    static var previews: some View {
//        UserList()
//    }
//}
