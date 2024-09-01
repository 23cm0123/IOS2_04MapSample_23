//
//  ContentView.swift
//  IOS2_04MapSample_23
//
//  Created by Kristen on 2024/04/30.
//

import SwiftUI
import MapKit // Map表示させる時には追加する

struct ContentView: View {
    
    @State var searchResults : [MKMapItem] = []
    // if without @State, will show error 「Cannot assign to property: 'self' is immutable」
    //    @State var searchSpotName: String = ""
    //
    //    @State var destination: String = ""
    //    @State var departure: String = ""
    
    //    @State var destinationPoint: CGFloat
    //    @State var departurePoint: CGFloat
    
    @ObservedObject var manager = LocationManager()
    
    @State var tapPoint: CLLocationCoordinate2D?
    
    // 2024.05.10　カメラの初期位置を設定する
    @State private var cameraPosition: MapCameraPosition =
        .region(MKCoordinateRegion(
            center: .jec7,
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    
    var body: some View {
        
        //        TextField("行きたい場所", text: $searchSpotName, prompt: Text("行きたい場所を入力してください"))
        //            .padding()
        //            .onSubmit() {
        //                searchSpot(for: searchSpotName)
        //            }
        
        //        TextField("出発地", text: $startingPoint, prompt: Text("出発地を入力してください"))
        //            .padding()
        ////            .onSubmit() {
        ////                calculateRoute(from: startingPoint, to: destinationPoint, transportType: .any)
        ////            }
        //
        //        TextField("目的地", text: $destinationPoint, prompt: Text("目的地を入力してください"))
        //            .padding()
        ////            .onSubmit() {
        ////                searchSpot(for: searchSpotName)
        ////            }
        
        // MapReader　→　Mapの情報を受け取るため
        //（なぜ受け取る：今私、画面を押した時この情報を知りたい）
        MapReader{ mapProxy in
            // initialPosition: cameraPosition → 初期位置
            Map(initialPosition: cameraPosition){
                //            Marker("新宿駅", coordinate: .shinjukuStation)
                // Marker vs Annotation → Marker looks like balloon; Annotation just image
                // もしcustomizeな図形使いたい時、Annotationの方が良い
                Marker("新宿駅", // pin に表示する text
                       systemImage: "train.side.front.car", // pinに表示するimage
                       coordinate: .shinjukuStation) // pinの座標(extension に設定された変数）
                //            .tint(.blue) // pinを青くする
                
                
                Annotation("日本電子専門学校 7号館", coordinate: .jec7){
                    //                Image(systemName: "graduationcap")
                    //                    .padding(4)
                    //                    .foregroundColor(.blue)
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.background)
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.secondary, lineWidth: 5)
                        Image(systemName: "book")
                            .padding(5)
                    }
                    
                    
                }
                
                UserAnnotation(anchor: .center) { userLocation in
                    VStack {
                        Image(systemName: "figure.wave")
                            .foregroundStyle(.red)
                        Text("現在地はここだよ")
                    }
                }
                
                // 自由追加 → 自習場所
                Marker("早稲田文学院", systemImage: "book.fill", coordinate: .waseda)
                Marker("TSUTAYA", systemImage: "book.fill", coordinate: .tsutaya)
                Marker("杉並區立中央圖書館", systemImage: "book.closed", coordinate: .suginami)
                Marker("板橋区立図書館", systemImage: "book.closed", coordinate: .itabashi)
                
                // 自由追加 → 行きたい場所
                //            Group{
                //                Marker("IMMERSIVE FORT", // pin に表示する text
                //                       systemImage: "figure.core.training", // pinに表示するimage
                //                       coordinate: .iMFT) // pinの座標(extension に設定された変数）
                //
                //
                //                Marker("Disney Sea", // pin に表示する text
                //                       systemImage: "figure.step.training", // pinに表示するimage
                //                       coordinate: .disneySea) // pinの座標(extension に設定された変数）
                //
                //
                //                //            Marker("コナン", // pin に表示する text
                //                //                   systemImage: "sunglasses", // pinに表示するimage
                //                //                   coordinate: .conan) // pinの座標(extension に設定された変数）
                //
                //
                //                Marker("ドラえもん", // pin に表示する text
                //                       systemImage: "flashlight.on.circle", // pinに表示するimage
                //                       coordinate: .doraAmon) // pinの座標(extension に設定された変数）
                //
                //                // draw circle in map
                //                MapCircle(center: .shinjukuStation, radius: 150)
                //                    .foregroundStyle(.blue.opacity(0.2))
                //
                //                // draw line in map
                //                MapPolyline(coordinates: [.shinjukuStation, .doraAmon])
                //                    .stroke(.red, lineWidth: 5)
                //
                //                // draw 多角形 in map(頂点の数で変わる)
                //                MapPolygon(coordinates: [.jec, .doraAmon, .disneySea])
                //                    .foregroundStyle(.orange.opacity(0.5))
                //            } //Group
                
                
                ForEach(searchResults, id: \.self){ result in
                    Marker(item: result)
                }
                
                if let routePolyLine = route?.polyline {
                    MapPolyline(routePolyLine)
                        .stroke(.red, lineWidth: 4)
                }
                
//                if let tapPoint {
//                    Marker(coordinate: tapPoint) {
//                        Text("タップしたところ")
//                    }
//                }
                
                
                
            } // Map
            .mapControls{
                MapUserLocationButton() // 跳去自己现在在的地方且zoom大
                MapPitchToggle() // 把地图变成3D模式
                MapCompass() // 显示陀螺仪
                    .mapControlVisibility(.visible)
                MapScaleView() // 显示缩尺
                
            }
//            .mapStyle(.imagery(elevation: .realistic))
//                    .mapStyle(.hybrid(elevation: .realistic)) // 3D map になる
            // imagery vs hybrid → hybrid with 道路の名前
            .onTapGesture(perform: { screenLocation in
                guard let location = mapProxy.convert(screenLocation, from: .local) else {
                    // 押したところの座標を送って、経緯度に変換して返す
                    return
                }
                print("タップした座標:" , location)
                tapPoint = location
            })
        } // MapReader
        
        HStack(spacing: 40){
            
            //            Button{
            //                searchSpot(for: "ラーメン")
            //            } label: {
            ////                Image(systemImage: "fork.knife.circle.fill")
            //                Image(systemName: "fork.knife.circle.fill")
            ////                    .background()
            //
            //            }
            ////            .buttonStyle(.borderedProminent)
            ////            .foregroundStyle(.opacity(0.5))
            //
            //            Button{
            //                searchSpot(for: "駐車場")
            //            } label: {
            //                Label("駐車場", systemImage: "parkingsign.circle.fill")
            //            }
            //            .buttonStyle(.borderedProminent)
            
            
            Button {
                Task {
                    await calculateRoute(from: .jec7, to: .shinjukuStation, transportType: .walking)
                }
            } label: {
                //                Image(systemImage: "fork.knife.circle.fill")
                Label("徒歩", systemImage: "figure.walk")
                //                    .background()
            }
            
            Button{
                Task {
                    await calculateRoute(from: .jec7, to: .shinjukuStation, transportType: .automobile)
                }
            } label: {
                //                Image(systemImage: "fork.knife.circle.fill")
                Label("車", systemImage: "car.fill")
                //                    .background()
            }
            
            Button{
                Task {
                    await calculateRoute(from: .jec7, to: .shinjukuStation, transportType: .any)
                }
            } label: {
                //                Image(systemImage: "fork.knife.circle.fill")
                Label("自転車", systemImage: "bicycle")
                //                    .background()
            }
            
            Button{
                Task {
                    await calculateRoute(from: .jec7, to: .waseda, transportType: .transit)
                    // !!!: transit は routeが出てこない、時間だけ出る
                }
            } label: {
                //                Image(systemImage: "fork.knife.circle.fill")
                Label("電車", systemImage: "tram.fill")
                //                    .background()
            }
            
            
            
            
            
            
        } // HStack for Button
        .padding()
        .labelStyle(.iconOnly)
        
    }
    
    /// centerの周りに探す店がある場所を表示する
    func searchSpot(for query: String){
        // request を投げるための情報？
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            center: manager.region.center,
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        )
        
        Task{
            let search = MKLocalSearch(request: request)
            
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []
        }
    }
    
    /// change destination wrote in textField to longitude & latitute
    //    func searchDestinationSpot(for query: String){
    //        let request = MKLocalSearch.Request()
    //        request.naturalLanguageQuery = query
    //        request.resultTypes = .pointOfInterest
    //
    //        Task{
    //            let search = MKLocalSearch(request: request)
    //
    //            let response = try? await search.start()
    //            if let mapItem = response?.mapItems.first {
    //                self.departurePoint = mapItem
    //            }
    //        }
    //    }
    
    
    @State private var route: MKRoute?
    /// ルート計算
    func calculateRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, transportType: MKDirectionsTransportType) async {
        
        let fromPlacemark = MKPlacemark(coordinate: from)
        let toPlacemark = MKPlacemark(coordinate: to)
        
        let request = MKDirections.Request()
        // create request data
        request.source = MKMapItem(placemark: fromPlacemark)
        request.destination = MKMapItem(placemark: toPlacemark)
        request.transportType = transportType
        // TODO: ↑ 車か徒歩か交通機関か、ここの引数を変わる
        
        if request.transportType == .transit{
            let directions = MKDirections(request: request)
            
            do {
                let etaResponse = try await directions.calculateETA()
                let etaSecond = etaResponse.expectedTravelTime
                let etaMinutes = Int(etaSecond / 60)
                print("ETA: \(etaMinutes)")
            } catch {
                print("error: \(error.localizedDescription)")
            }
            
        } else {
            
            do {
                
                let directions = MKDirections(request: request)
                let response = try await directions.calculate()
                let routes = response.routes
                route = routes.first
                
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
        
    }
    
}

// JR新宿駅　35.6888513　139.6984545
// 日本电子专门学校  35.698425,139.6958348

// IMMERSIVE FORT TOKYO/@35.625017,139.7773411
// 东京迪士尼海洋/@35.6267151,139.882503
// 柯南之家+米花商店街/@35.4928539,133.7566292
// 藤子·F·不二雄博物馆/@35.6099272,139.5709974

// 自習場所：
// 日本電子専門学校+7号館//@35.6989225,139.6554022
// 早稲田文学院：35.7097306,139.7173257
// TSUTAYA+BOOKSTORE+MARUNOUCHI/@35.6810117,139.7612022
// 杉並區立中央圖書館/@35.701846,139.5917421
// Itabashi+City+Central+Library/@35.7019904,139.5299408


// 位置情報を取り扱う構造体　CLLocationCoordinate2Dを利用する
extension CLLocationCoordinate2D{
    // !!!: x は longtitude
    static let shinjukuStation = CLLocationCoordinate2D(latitude: 35.6888513, longitude: 139.6984545)
    static let jec = CLLocationCoordinate2D(latitude: 35.698425, longitude: 139.6958348)
    static let jec7 = CLLocationCoordinate2D(latitude: 35.6989225, longitude: 139.6554022)
    
    static let waseda = CLLocationCoordinate2D(latitude: 35.7097306, longitude: 139.7173257)
    static let tsutaya = CLLocationCoordinate2D(latitude: 35.6810117, longitude: 139.7612022)
    static let suginami = CLLocationCoordinate2D(latitude: 35.701846, longitude: 139.5917421)
    static let itabashi = CLLocationCoordinate2D(latitude: 35.7019904, longitude: 139.5299408)
    
    //    static let iMFT = CLLocationCoordinate2D(latitude: 35.625017, longitude: 139.7773411)
    //    static let disneySea = CLLocationCoordinate2D(latitude: 35.6267151, longitude: 139.882503)
    //    static let conan = CLLocationCoordinate2D(latitude: 35.4928539, longitude: 133.7566292)
    //    static let doraAmon = CLLocationCoordinate2D(latitude: 35.6099272, longitude: 139.5709974)
    
    
    
}



#Preview {
    ContentView()
}
