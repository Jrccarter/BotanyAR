//
//  Models.swift
//  2023HATCHTest2
//
//  Created by Jake Carter on 3/4/23.
//

import UIKit
import RealityKit
import Combine

class Models {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                // handles errors
                print ("DEBUG: Unable to load Model for: \(self.modelName)")
            },
                  receiveValue: { modelEntity in
                // Gets Model Entity
                self.modelEntity = modelEntity
                print ("DEBUG: Successfully able to load Model: \(self.modelName)")
            })
        
    }
    
}
