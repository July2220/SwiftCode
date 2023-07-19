//
//  File.swift
//  Earthquakes-iOS
//
//  Created by july on 2023/7/19.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

// 1. Implement the properties and required coding keys

struct RawServerResponse {
    enum RootKeys: String, CodingKey {
        case type, properties, geometry, id
    }
    
    enum PropertiesKeys: String, CodingKey {
        case products
    }
    
    enum ProductsKeys: String, CodingKey {
        case origin
    }
    
    enum OriginKeys: String, CodingKey {
        case properties
    }
    
    enum NestedPropertiesKeys: String, CodingKey {
        case latitude,longitude
    }
    
    let id: String
    let latitude: Double
    let longitude: Double
}

// 2. Set the decoding strategy for properties

extension RawServerResponse: Decodable {
    init(from decoder: Decoder) throws {
        // id
        let container = try decoder.container(keyedBy: RootKeys.self)//top-level
        id = try container.decode(String.self, forKey: .id)
        
        //lat&long
        let propertiesContainer = try container.nestedContainer(keyedBy: PropertiesKeys.self, forKey: .properties)
        let productsContainer = try propertiesContainer.nestedContainer(keyedBy: ProductsKeys.self, forKey: .products)
        
        //container for []，must be a var
        var originContainer = try productsContainer.nestedUnkeyedContainer(forKey: .origin)
        //container for [].first
        let firstOriginContainer = try originContainer.nestedContainer(keyedBy: OriginKeys.self)
        
        let nestPropertiesContainer = try firstOriginContainer.nestedContainer(keyedBy: NestedPropertiesKeys.self, forKey: .properties)
        
        let latitude = try nestPropertiesContainer.decode(String.self, forKey: .latitude) //JSON 文档里面是 String
        let longitude = try nestPropertiesContainer.decode(String.self, forKey: .longitude)
        
        guard let latitude = Double(latitude), let longitude = Double(longitude) else { throw QuakeError.missingData  }
        self.latitude = latitude
        self.longitude = longitude
    }
}

/*
 A keyed container is used to decode a JSON object, and is decoded with a CodingKey conforming type (such as the ones we've defined above).

 An unkeyed container is used to decode a JSON array, and is decoded sequentially (i.e each time you call a decode or nested container method on it, it advances to the next element in the array). See the second part of the answer for how you can iterate through one.
 */
