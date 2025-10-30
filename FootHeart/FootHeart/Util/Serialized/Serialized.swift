//
//  Serialized.swift
//  FootHeart
//
//  Created by Jupond on 10/23/25.
//
import Foundation

extension UserDefaults {
    
    /// Codable 객체를 UserDefaults에 저장
    func setCodable<T: Codable>(_ value: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            set(encoded, forKey: key)
        }
    }
    
    /// UserDefaults에서 Codable 객체 가져오기
    func codable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
    
    /// Codable 객체 삭제
    func removeCodable(forKey key: String) {
        removeObject(forKey: key)
    }
}
