//
//  ThemeWalkingProtocol.swift
//  FootHeart
//
//  Created by Jupond on 6/11/25.
//
import Combine

protocol ThemeWalkingProtocol {
    func fetchThemeWalkingList(page : Int, limit : Int) -> AnyPublisher<[ThemeWalkingModel], Error>
    func addTheme(model : ThemeWalkingModel) -> AnyPublisher<Void, Error>
    func refreshThemeWalkingList() -> AnyPublisher<[ThemeWalkingModel], Error> 

}
