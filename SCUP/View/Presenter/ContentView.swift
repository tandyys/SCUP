//
//  ContentView.swift
//  SCUP
//
//  Created by Vincent Saranang on 24/04/24.
//

import SwiftUI
import FirebaseStorage
import SwiftData


struct Line {
    var points: [CGPoint]
    var color: Color
    var size: CGFloat
}

class DrawingManager: ObservableObject {
    @Published var lines: [Line] = []
    @Published var selectedColor: Color = .black
    @Published var lineSize: CGFloat = 5
    
    private var undoStack: [Line] = []
    private var redoStack: [Line] = []
    
    func addLine(_ line: Line) {
        lines.append(line)
        undoStack.append(line)
    }
    
    func undo() {
        guard let lastLine = lines.last else { return }
        undoStack.removeLast()
        redoStack.append(lastLine)
        lines.removeLast()
    }
    
    func redo() {
        guard let lastRedoLine = redoStack.popLast() else { return }
        undoStack.append(lastRedoLine)
        lines.append(lastRedoLine)
    }
    
    func clear() {
        lines.removeAll()
        undoStack.removeAll()
        redoStack.removeAll()
    }
    
    func captureCanvas() -> UIImage? {
        let canvasSize = CGSize(width: 1024, height: 1024)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        for line in lines {
            if let cgColor = line.color.cgColor {
                context.setStrokeColor(cgColor)
            }
            context.setLineWidth(line.size)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            context.addLines(between: line.points)
            context.strokePath()
        }
        
        let canvasImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return canvasImage
    }

}

private enum AlertType {
    case isDownload, isClear
}
struct ContentView: View {
    @ObservedObject private var drawingManager = DrawingManager()
    @State private var isPopoverPresented = false
    @State private var isDownloadAlertPresented = false
    @State private var activeAlert = false
    
    @State private var currentLine: Line?
    @State private var alertId : AlertType = .isClear
    
    @Environment(\.modelContext) var context
    @Query var sketches : [SketchModel]
    
    @State var trigger : Bool = false
    
    @State private var isUploading = false
    @State private var uploadProgress = 0.0
    @State private var isAPICalling = false
    @State private var apiCallProgress = 0.0
    @State private var showOutputView = false
    @State private var isError = false
    
    @State private var outputImageURL : String = ""
    @State var sketchToReimagine : SketchModel?
    @State var sketchID : PersistentIdentifier?
    
    /**
     
     ButtonContainerView(
         selectedColor: $drawingManager.selectedColor,
         lineSize: $drawingManager.lineSize,
         undoAction: drawingManager.undo,
         redoAction: drawingManager.redo,
         clearAction: drawingManager.clear,
         downloadAction: {
             isDownloadAlertPresented.toggle()
             
         },
         reimagineAction: {
             Task {
                 await reimagineSketch()
             }
         }
     )
     */
    
    var body: some View {
        ZStack {
            HStack {
                VStack {
                    ButtonContainerView(
                        selectedColor: $drawingManager.selectedColor,
                        lineSize: $drawingManager.lineSize,
                        undoAction: drawingManager.undo,
                        redoAction: drawingManager.redo,
                        clearAction: drawingManager.clear,
                        saveAction: {
//                            activeAlert.toggle()
//                            self.alertId = .isDownload
                            Task {
                                await reimagineSketch(uploadSketchOnly: true)    
                            }
                        },
                        reimagineAction: {
                            Task {
                                await reimagineSketch()
                            }
                        }
                    )
                    GeometryReader { geometry in
                        ScrollView([.horizontal, .vertical]) {
                            ZStack {
                                Canvas { context, size in
                                    for line in drawingManager.lines {
                                        var path = Path()
                                        path.addLines(line.points)
                                        
                                        if let cgColor = line.color.cgColor { // Unwrap optional CGColor safely
                                            context.stroke(path, with: .color(Color(cgColor)), style: StrokeStyle(lineWidth: line.size, lineCap: .round, lineJoin: .round))
                                        }
                                    }
                                    
                                    if let currentLine = currentLine {
                                        var path = Path()
                                        path.addLines(currentLine.points)
                                        
                                        if let cgColor = currentLine.color.cgColor {
                                            context.stroke(path, with: .color(Color(cgColor)), style: StrokeStyle(lineWidth: currentLine.size, lineCap: .round, lineJoin: .round))
                                        }
                                    }
                                }
                                .frame(width: 1024, height: 1024)
                                .background(Color(hex: 0xFFFFFF))
                                .gesture(DragGesture(minimumDistance: 0)
                                    .onChanged({ value in
                                        let touchPoint = value.location
                                        updateCurrentLine(with: touchPoint)
                                    })
                                    .onEnded({ _ in
                                        if let currentLine = currentLine {
                                            drawingManager.addLine(currentLine)
                                        }
                                        self.currentLine = nil
                                    })
                                )
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                        }
                    }
                    .padding()
                }
            }
            .background(Color(hex: 0xFFFFFF))
            
            VStack {
                Spacer()
                HStack {
                    VStack {
                        Button(action: {
                            isPopoverPresented.toggle()
                        }) {
                            Image("PopOver")
                                .resizable()
                                .frame(width: 52, height: 52)
                                .padding(16)
                        }
                        .background(Color.white)
                        .cornerRadius(32)
                        .shadow(radius: 4)
                    }
                    .padding(.horizontal, 24)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .padding()
            
            if isPopoverPresented {
                VStack {
                    clearButton()
                    Spacer()
                    VStack {
                        Slider(value: $drawingManager.lineSize, in: 1...20, step: 1)
                            .padding(.vertical)
                    }
                    .rotationEffect(.degrees(-90))
                    .frame(width: 240)
                    Spacer()
                    ColorPicker("", selection: $drawingManager.selectedColor)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(width: 40, height: 400)
                .padding()
                .background(Color.white)
                .cornerRadius(28)
                .position(x: 80, y: UIScreen.main.bounds.height / 2)
                .shadow(radius: 8)
            }
            if showOutputView {
                OutputView(sketch: sketchToReimagine!)
            }
        }
        .background(Color.clear)
        .padding(showOutputView ? 10 : 11)
        .alert(isPresented: $activeAlert) {
            print(alertId)
            switch alertId {
            case .isDownload:
                let canvasImage = drawingManager.captureCanvas()
                    if let imageData = canvasImage?.jpegData(compressionQuality: 1) {
                        return Alert(title: Text("Download Canvas"), message: Text("Do you want to save the canvas to your photo library?"), primaryButton: .default(Text("Save"), action: {
                                UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
                            }), secondaryButton: .cancel())
                    } else {
                        return Alert(title: Text("Error"), message: Text("Failed to capture canvas. Please try again."), dismissButton: .default(Text("OK")))
                    }
            case .isClear:
                return Alert(title: Text("Clear Canvas"), message: Text("Are you sure you want to clear the canvas?"), primaryButton: .destructive(Text("Clear"), action: {
                    drawingManager.clear()
                    }), secondaryButton: .cancel())

            }
        }
    }
    
    
    func reimagineSketch(uploadSketchOnly: Bool = false) async {
        print("Processing and uploading sketch...")
        // Create storage ref
        let storageRef = Storage.storage().reference()
        if sketchToReimagine == nil {
            // Make new sketch object (SketchModel)
            let sketchObj = SketchModel()
            // Save sketch object to container
            context.insert(sketchObj)
            // Get image data and name (get name from sketch object id)
            print("New sketch id:", sketchObj.id)
            print("Sketches len:", sketches.count)
            
            let canvasImage = drawingManager.captureCanvas()
            guard canvasImage != nil else {
                print("canvasImage is nil"); return
            }
            guard let imageData = canvasImage?.jpegData(compressionQuality: 1) else {
                print("Error converting image"); return
            }
            // Specify the file path and name
            let fileRef = storageRef.child("sketches/\(sketchObj.id).jpg")
            // Upload the sketch image to firebase
            _ = fileRef.putData(imageData, metadata: nil) { metadata, error in
                if error == nil && metadata != nil {
                    // Fetch the download URL
                    fileRef.downloadURL { url, error in
                        if let error = error {
                            // Handle any errors
                            print("err:", error)
                        } else {
                            // Get the download URL'
                            print("url:", url?.absoluteString ?? "")
                            sketchObj.sketchURL = url?.absoluteString ?? ""
                            
                            // API Calls
                            sketchToReimagine = sketchObj
                            sketchID = sketchObj.persistentModelID
                            print(sketchToReimagine?.id ?? "-1")
                            if !uploadSketchOnly {
                                showOutputView.toggle()
                            }
                        }
                    }
                } else {
                    print("Error uploading to firebase")
                }
            }
        } else {
            guard let sketchObj = context.model(for: sketchID!) as? SketchModel else {
                return
            }
            print("Old canvas")
            print(sketchObj.id)
            let canvasImage = drawingManager.captureCanvas()
            guard canvasImage != nil else {
                print("canvasImage is nil"); return
            }
            guard let imageData = canvasImage?.jpegData(compressionQuality: 1) else {
                print("Error converting image"); return
            }
            // Specify the file path and name
            let fileRef = storageRef.child("sketches/\(sketchObj.id).jpg")
            // Upload the sketch image to firebase
            _ = fileRef.putData(imageData, metadata: nil) { metadata, error in
                if error == nil && metadata != nil {
                    // Fetch the download URL
                    fileRef.downloadURL { url, error in
                        if let error = error {
                            // Handle any errors
                            print("err:", error)
                        } else {
                            // Get the download URL'
                            print("url:", url?.absoluteString ?? "")
                            sketchObj.sketchURL = url?.absoluteString ?? ""
                            
                            // API Calls
                            sketchToReimagine = sketchObj
                            if !uploadSketchOnly {
                                showOutputView.toggle()
                            }
                        }
                    }
                } else {
                    print("Error uploading to firebase")
                }
            }
            
        }
        
    }
   
    @ViewBuilder
    func clearButton() -> some View {
        Button {
            activeAlert.toggle()
            self.alertId = .isClear
        } label: {
            Image("Trash")
                .resizable()
                .frame(width: 40, height: 40)
                .padding()
                .font(.largeTitle)
                .foregroundColor(.red)
        }
    }
    
    func updateCurrentLine(with point: CGPoint) {
        var updatedLine = currentLine ?? Line(points: [], color: drawingManager.selectedColor, size: drawingManager.lineSize)
        updatedLine.points.append(point)
        currentLine = updatedLine
    }
}


struct ButtonContainerView: View {
    @Binding var selectedColor: Color
    @Binding var lineSize: CGFloat
    var undoAction: () -> Void
    var redoAction: () -> Void
    var clearAction: () -> Void
    var saveAction: () -> Void
    var reimagineAction: () -> Void
    
    var body: some View {
        HStack() {
            Button(action: undoAction) {
                Image("Undo")
                    .resizable()
                    .frame(width: 52, height: 52)
                    .padding(16)
                    .background(Color.white)
                    .foregroundColor(.primary)
                    .cornerRadius(32)
            }.padding(.trailing)
                .shadow(radius: 4)
            Button(action: redoAction) {
                Image("Redo")
                    .resizable()
                    .frame(width: 52, height: 52)
                    .padding(16)
                    .background(Color.white)
                    .foregroundColor(.primary)
                    .cornerRadius(32)
            }.padding(.trailing)
                .shadow(radius: 4)
//            Buat prevent mistake, clear allnya di pop-up aj
//            Button(action: clearAction) {
//                Image(systemName: "trash.circle.fill")
//                    .font(.title)
//                    .padding()
//                    .background(Color.white)
//                    .foregroundColor(.primary)
//                    .cornerRadius(10)
//            }
            Button(action: saveAction) {
                Image("DownloadImage")
                    .resizable()
                    .frame(width: 52, height: 52)
                    .padding(16)
                    .background(Color.white)
                    .foregroundColor(.primary)
                    .cornerRadius(32)
            }.padding(.trailing)
                .shadow(radius: 4)
            Button(action: reimagineAction) {
                Image("Reimaging")
                    .resizable()
                    .frame(width: 52, height: 52)
                    .padding(16)
                    .background(Color.white)
                    .foregroundColor(.primary)
                    .cornerRadius(32)
                    
            }.padding(.trailing)
                .shadow(radius: 4)
        }
    }
}

extension Color {
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: false)
    let container = try! ModelContainer(for: SketchModel.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}
