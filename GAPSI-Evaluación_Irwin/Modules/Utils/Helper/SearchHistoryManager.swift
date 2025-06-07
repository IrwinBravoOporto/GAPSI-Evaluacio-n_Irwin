//
//  SearchHistoryManager.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

// SearchHistoryManager.swift
import Foundation

protocol SearchHistoryManagerProtocol {
    func saveSearchTerm(_ term: String)
    func getSearchHistory() -> [String]
    func clearSearchHistory()
}

class SearchHistoryManager: SearchHistoryManagerProtocol {
    static let shared = SearchHistoryManager()
    private let userDefaults = UserDefaults.standard
    private let searchHistoryKey = "SearchHistoryKey"
    
    private init() {}
    
    func saveSearchTerm(_ term: String) {
        var history = getSearchHistory()
        
        // Evitar duplicados y mantener un orden
        if let index = history.firstIndex(of: term) {
            history.remove(at: index)
        }
        
        history.insert(term, at: 0)
        
        // Limitar el historial a los últimos 10 términos
        if history.count > 10 {
            history = Array(history.prefix(10))
        }
        
        userDefaults.set(history, forKey: searchHistoryKey)
    }
    
    func getSearchHistory() -> [String] {
        return userDefaults.stringArray(forKey: searchHistoryKey) ?? []
    }
    
    func clearSearchHistory() {
        userDefaults.removeObject(forKey: searchHistoryKey)
    }
}
