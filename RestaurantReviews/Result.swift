//
//  Result.swift
//  RestaurantReviews
//
//  Created by Francisco Ozuna on 3/30/20.
//  Copyright © 2020 Treehouse. All rights reserved.
//

import Foundation

// the enum Result is generic over two types, meaning it has two generic type parameters, T and U
enum Result<T, U> where U: Error {
    case success(T)
    case failure(U)
}
