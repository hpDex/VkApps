//
//  GetPhotosFriend.swift
//  Client VK
//
//  Created by Denis Filippov on 02.03.2022.
//  Copyright © 2022 Vasily Petuhov. All rights reserved.
//

import Foundation

struct PhotosResponse: Decodable {
    var response: Response
    
    struct Response: Decodable {
        var count: Int
        var items: [Items]
        
        struct Items: Decodable {
            var album_id: Int
            var date: Int
            var id: Int
            var owner_id: Int
            var has_tags: Bool
            var sizes: [Sizes]
            var text: String
            
            struct Sizes: Decodable {
                var height: Int
                var url: String
                var type: String
                var width: Int
            }
        }
    }
}


class GetPhotosFriend {
    
    //данные для авторизации в ВК
    func loadData(owner_id: String, complition: @escaping ([String]) -> Void ) {
        
        // Конфигурация по умолчанию
        let configuration = URLSessionConfiguration.default
        // собственная сессия
        let session =  URLSession(configuration: configuration)
        
        // конструктор для URL
        var urlConstructor = URLComponents()
        urlConstructor.scheme = "https"
        urlConstructor.host = "api.vk.com"
        urlConstructor.path = "/method/photos.getAll"
        urlConstructor.queryItems = [
            URLQueryItem(name: "owner_id", value: owner_id),
            URLQueryItem(name: "access_token", value: Session.instance.token),
            URLQueryItem(name: "v", value: "5.131")
        ]
                
        // задача для запуска
        let task = session.dataTask(with: urlConstructor.url!) { (data, response, error) in
            //print("Запрос к API: \(urlConstructor.url!)")
            
            // в замыкании данные, полученные от сервера, мы преобразуем в json
            guard let data = data else { return }
            
            do {
                let arrayPhotosFriend = try JSONDecoder().decode(PhotosResponse.self, from: data)
                var photosFriend: [String] = []
                
                for i in 0...arrayPhotosFriend.response.items.count-1 {
                    if let urlPhoto = arrayPhotosFriend.response.items[i].sizes.last?.url {
                        photosFriend.append(urlPhoto)
                    }
                }
                complition(photosFriend)
            } catch let error {
                print(error)
                complition([])
            }
        }
        task.resume()
    }
    
}