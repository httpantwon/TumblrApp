//
//  Post.swift
//  ios101-project5-tumbler
//

import Foundation

struct Blog: Decodable {
    let response: Response
}

struct Response: Decodable {
    let posts: [Post]
}

struct Post: Decodable {

    /// A brief truncated version of the post caption
    let summary: String

    /// The full blog post caption
    let caption: String
    let photos: [Photo]
}

struct Photo: Decodable {
     let originalSize: PhotoInfo

    enum CodingKeys: String, CodingKey {

        // Maps API key name to a more "swifty" version (i.e. lowerCamelCasing and no `_`)
        case originalSize = "original_size"
    }
}

struct PhotoInfo: Decodable {

    // The url for the location of the photo image
    let url: URL
}
