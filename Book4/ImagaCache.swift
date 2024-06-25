//
//  ImagaCache.swift
//  Book4
//
//  Created by 김진규 on 6/25/24.
//

import Foundation
import SwiftUI

class ImageCache {
    private var cache = NSCache<NSString, UIImage>()

    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: NSString(string: key))
    }

    func set(forKey key: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: key))
    }
}
