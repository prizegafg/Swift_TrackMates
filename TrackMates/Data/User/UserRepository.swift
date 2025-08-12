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
    func wipeAll(_ completion: @escaping (Result<Void, Error>) -> Void)
}
// MARK: - Write
final class UserRepository: UserRepositoryProtocol {
    private let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func replaceLocal(_ user: UserEntity, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform {
            do {
                // Hapus record dengan id sama (class-agnostic)
                let fetch = NSFetchRequest<NSManagedObject>(entityName: "User")
                fetch.predicate = NSPredicate(format: "id == %@", user.id)
                for obj in try self.context.fetch(fetch) { self.context.delete(obj) }
                
                // Insert baru (tanpa tergantung subclass)
                let obj = NSEntityDescription.insertNewObject(forEntityName: "User", into: self.context)
                self.apply(user, to: obj)
                
                try self.context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}


// MARK: - Read
extension UserRepository {
    func current(_ completion: @escaping (Result<UserEntity?, Error>) -> Void) {
        let req = NSFetchRequest<NSManagedObject>(entityName: "User")
        req.fetchLimit = 1
        do {
            let obj = try context.fetch(req).first
            completion(.success(obj.flatMap { mapEntity($0) }))
        } catch {
            completion(.failure(error))
        }
    }
    
    func get(_ id: String, _ completion: @escaping (Result<UserEntity?, Error>) -> Void) {
        let req = NSFetchRequest<NSManagedObject>(entityName: "User")
        req.predicate = NSPredicate(format: "id == %@", id)
        req.fetchLimit = 1
        do {
            let obj = try context.fetch(req).first
            completion(.success(obj.flatMap { mapEntity($0) }))
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: - Delete
extension UserRepository {
    func wipeAll(_ completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform {
            do {
                let psc = self.container.persistentStoreCoordinator
                let model = psc.managedObjectModel
                for entity in model.entities {
                    guard let name = entity.name else { continue }
                    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                    let deleteReq = NSBatchDeleteRequest(fetchRequest: fetch)
                    // Nggak perlu merge OIDs satu2; reset context sesudahnya
                    _ = try psc.execute(deleteReq, with: self.context)
                }
                self.context.reset()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
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
            let dob = dateOfBirth,
            let bio = bio
        else { return nil }
        return UserEntity(
            id: id,
            username: username,
            firstName: firstName,
            lastName: lastName,
            email: email,
            dateOfBirth: dob,
            bio: bio
        )
    }
}

private extension UserRepository {
    func apply(_ user: UserEntity, to obj: NSManagedObject) {
        obj.setValue(user.id,            forKey: "id")
        obj.setValue(user.username,      forKey: "username")
        obj.setValue(user.firstName,     forKey: "firstName")
        obj.setValue(user.lastName,      forKey: "lastName")
        obj.setValue(user.email,         forKey: "email")
        obj.setValue(user.dateOfBirth,   forKey: "dateOfBirth")
        obj.setValue(user.bio ?? "",     forKey: "bio")
    }
    func mapEntity(_ obj: NSManagedObject) -> UserEntity? {
        guard
            let id        = obj.value(forKey: "id") as? String,
            let username  = obj.value(forKey: "username") as? String,
            let email     = obj.value(forKey: "email") as? String,
            let dob       = obj.value(forKey: "dateOfBirth") as? Date
        else { return nil }
        // first/last name & bio boleh kosong di awal
        let firstName = (obj.value(forKey: "firstName") as? String) ?? ""
        let lastName  = (obj.value(forKey: "lastName")  as? String) ?? ""
        let bio       = (obj.value(forKey: "bio")       as? String)
        return UserEntity(id: id, username: username, firstName: firstName, lastName: lastName, email: email, dateOfBirth: dob, bio: bio)
    }
}
