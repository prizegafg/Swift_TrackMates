//
//  UserRepository.swift
//  TrackMates
//
//  Created by Prizega Fromadia on 06/08/25.
//

import Foundation
import CoreData
import UIKit

protocol UserRepositoryProtocol {
    func replaceLocal(_ user: UserEntity, completion: @escaping (Result<Void, Error>) -> Void)
}

final class UserRepository: UserRepositoryProtocol {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func replaceLocal(_ user: UserEntity, completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<UserCD> = UserCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", user.id)
        do {
            // Remove existing user if any (replace strategy)
            let results = try context.fetch(fetchRequest)
            for existingUser in results {
                context.delete(existingUser)
            }
            let cdUser = UserCD(context: context)
            cdUser.id = user.id
            cdUser.username = user.username
            cdUser.firstName = user.firstName
            cdUser.lastName = user.lastName
            cdUser.email = user.email
            cdUser.dateOfBirth = user.dateOfBirth
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
