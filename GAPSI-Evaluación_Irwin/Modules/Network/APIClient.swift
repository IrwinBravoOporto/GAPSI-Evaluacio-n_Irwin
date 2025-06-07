//
//  APIClient.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

//
//  APIClient.swift
//  GAPSI-Evaluación_Irwin
//
//  Created by Irwin Bravo Oporto on 7/06/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case apiError(String)
    case httpError(Int, String)
}

protocol APIClientProtocol {
    func request<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, NetworkError>) -> Void)
}

class APIClient: APIClientProtocol {
    private let apiKey = "fce0e15738msh6a87c0c9db9505cp14b74fjsn54bc768f3bc7"
    
    func request<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.host
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            print("❌ Error: URL inválida - Componentes: \(components)")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("🌐 Request URL: \(url.absoluteString)")
        print("🔑 Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("⚡ Método: \(request.httpMethod ?? "N/A")")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Verificar error primero
            if let error = error {
                print("🔥 Error en la solicitud: \(error.localizedDescription)")
                completion(.failure(.apiError("Error de red: \(error.localizedDescription)")))
                return
            }
            
            // Verificar respuesta HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                print("⚠️ Respuesta HTTP inválida")
                completion(.failure(.apiError("Respuesta HTTP inválida")))
                return
            }
            
            print("📡 Response Code: \(httpResponse.statusCode)")
            print("📦 Response Headers: \(httpResponse.allHeaderFields)")
            
            // Verificar códigos de estado HTTP
            if !(200...299).contains(httpResponse.statusCode) {
                let errorMessage: String
                
                // Intentar extraer mensaje de error del cuerpo de la respuesta
                if let data = data,
                   let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    errorMessage = errorResponse.message
                    print("📄 Mensaje de error de la API: \(errorMessage)")
                } else {
                    // Mensajes predeterminados para códigos comunes
                    switch httpResponse.statusCode {
                    case 400: errorMessage = "Solicitud incorrecta"
                    case 401: errorMessage = "No autorizado"
                    case 403: errorMessage = "Acceso prohibido (API key inválida o no suscrito)"
                    case 404: errorMessage = "Recurso no encontrado"
                    case 500...599: errorMessage = "Error del servidor (\(httpResponse.statusCode))"
                    default: errorMessage = "Error HTTP (\(httpResponse.statusCode))"
                    }
                }
                
                print("🔴 Error HTTP \(httpResponse.statusCode): \(errorMessage)")
                completion(.failure(.httpError(httpResponse.statusCode, errorMessage)))
                return
            }
            
            // Verificar datos
            guard let data = data else {
                print("⚠️ No se recibieron datos en la respuesta")
                completion(.failure(.noData))
                return
            }
            
            // Imprimir datos JSON en crudo para depuración
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Raw JSON Response (truncado): \(String(jsonString.prefix(500)))...") // Mostrar solo los primeros 500 caracteres
            }
            
            // Decodificar respuesta
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                print("✅ Decodificación exitosa")
                completion(.success(decodedData))
            } catch let decodingError {
                print("🔴 Error de decodificación: \(decodingError)")
                print("Error localizado: \(decodingError.localizedDescription)")
                
                // Intentar mostrar más detalles del error de decodificación
                if let decodingError = decodingError as? DecodingError {
                    print("🧐 Detalles del error de decodificación:")
                    switch decodingError {
                    case .dataCorrupted(let context):
                        print("Datos corruptos: \(context)")
                    case .keyNotFound(let key, let context):
                        print("Clave no encontrada: \(key.stringValue) - \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Tipo no coincide: \(type) - \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Valor no encontrado: \(type) - \(context.debugDescription)")
                    @unknown default:
                        print("Error de decodificación desconocido")
                    }
                }
                
                completion(.failure(.decodingError))
            }
        }
        
        task.resume()
    }
}

// Estructura para manejar respuestas de error estándar de la API
struct APIErrorResponse: Decodable {
    let message: String
    let code: Int?
}
