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
    func current(_ completion: @escaping (Result<UserEntity?, Error>) -> Void)
    func get(_ id: String, _ completion: @escaping (Result<UserEntity?, Error>) -> Void)
}
// MARK: - Write
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


// MARK: - Read
extension UserRepository {
    func current(_ completion: @escaping (Result<UserEntity?, Error>) -> Void) {
        // ambil user pertama (atau terakhir login kalau kamu nanti simpan metadata)
        let req: NSFetchRequest<UserCD> = UserCD.fetchRequest()
        req.fetchLimit = 1
        do {
            let cd = try context.fetch(req).first
            completion(.success(cd.flatMap { $0.toEntity() }))
        } catch {
            completion(.failure(error))
        }
    }

    func get(_ id: String, _ completion: @escaping (Result<UserEntity?, Error>) -> Void) {
        let req: NSFetchRequest<UserCD> = UserCD.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id)
        req.fetchLimit = 1
        do {
            let cd = try context.fetch(req).first
            completion(.success(cd.flatMap { $0.toEntity() }))
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: - Mapper
private extension UserCD {
    func toEntity() -> UserEntity? {
        guard
            let id = id,
            let username = username,
            let firstName = firstName,
            let lastName = lastName,
            let email = email,
            let dob = dateOfBirth
        else { return nil }
        return UserEntity(id: id, username: username, firstName: firstName, lastName: lastName, email: email, dateOfBirth: dob)
    }
}
