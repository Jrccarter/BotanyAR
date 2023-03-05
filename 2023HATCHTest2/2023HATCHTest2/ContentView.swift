//
//  ContentView.swift
//  2023HATCHTest2
//
//  Created by Jake Carter on 3/4/23.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Models?
    @State private var modelConfirmedForPlacement:
        Models?
    
    private var modelname: [Models] = { // dynamically getting our file names
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let
                files = try?
                filemanager.contentsOfDirectory(atPath: path)
        else {
            return[]
        }
        
        var availableModels: [Models] = []
        for filename in files where
        filename.hasSuffix("usdz") {
            let modelName = filename.replacingOccurrences(of: ".usdz" , with: "")
            let models = Models(modelName: modelName)
            
            availableModels.append(models)
        }
        return availableModels
        
    }()
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedPlacement: self.$modelConfirmedForPlacement)
            
            if self.isPlacementEnabled {
                PlacementButtonView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            } else {
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled,selectedModel:
                                    self.$selectedModel, modelname: self.modelname)
                }
            }
        }
    }



    struct ModelPickerView: View {
        @Binding var isPlacementEnabled: Bool
        @Binding var selectedModel: Models?
        
        var modelname: [Models]
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 30) {
                    ForEach(0 ..< self.modelname.count) {
                        index in
                        Button(action: {print("DEBUG: selected model with name:  \(self.modelname[index].modelName)")
                            
                            self.selectedModel = self.modelname[index]
                        self.isPlacementEnabled = true
                    })
                        {
                            Image(uiImage: self.modelname[index].image)
                                .resizable()
                                .frame(height: 80) // pixel height
                                .aspectRatio(1/1, contentMode: .fit)
                                .background(Color.white)
                                .cornerRadius(12)
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                }
                
            }
            .padding(20)
            .background(Color.black.opacity(0.5))
            
        }
    }
    
    struct ARViewContainer: UIViewRepresentable {
        
        @Binding var modelConfirmedPlacement: Models?
        
        func makeUIView(context: Context) -> ARView {
            
            let arView = ARView(frame: .zero)
           
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal, .vertical]
            config.environmentTexturing = .automatic
            if ARWorldTrackingConfiguration
                .supportsSceneReconstruction(.mesh) {
                config.sceneReconstruction = .mesh
                
                arView.session.run(config)
            }
            
            return arView
        }
        
        func updateUIView(_ uiView: ARView, context: Context) {
            if let model = self.modelConfirmedPlacement {
                
                if let modelEntity = model.modelEntity {
                    print ("DEBUG: Addition of Model \(model.modelName)")
                    
                    let anchorEntity = AnchorEntity(plane:
                            .any)
                    anchorEntity.addChild(modelEntity.clone(recursive: true))
                    
                    uiView.scene.addAnchor(anchorEntity)
                } else {
                    print ("DEBUG: Unable to load Model \(model.modelName)")
                
                }
                
                DispatchQueue.main.async {
                    self.modelConfirmedPlacement = nil
                }
            }
            
        }
        
    }

struct PlacementButtonView: View {
    
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Models?
    @Binding var modelConfirmedForPlacement: Models?
    
    var body: some View {
        
        HStack {
            // Cancel Button
            Button(action: {print("DEBUG: Cancel model placement.")
                self.resetPlacementParameters()
                
            })
            {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            
            //Confirm Button
            Button(action: {print("DEBUG: Confirm model placement.")
                
                self.modelConfirmedForPlacement = self.selectedModel
                
                self.resetPlacementParameters()
                
            })
            {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
                }
            }
    }
    
    func resetPlacementParameters() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
        
    }
    
}

    
#if DEBUG
    struct ContentView_Previews : PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
#endif

