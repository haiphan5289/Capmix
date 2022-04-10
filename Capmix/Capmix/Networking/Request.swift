//
//  RequestService.swift
//  Kiple
//
//  Created by TVT on 8/9/17.
//  Copyright © 2017 com.futurify.vn. All rights reserved.
//

import Foundation
import Alamofire
import NVActivityIndicatorView
import Codextended
import RxCocoa
import RxSwift
import SwiftyJSON

typealias CompleteHandleJSONCode = (_ isSuccess: Bool, _ json: Any?, _ statusCode: Int?)->()
var isShowAlert = false

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

struct RequestService {
    private let disposeBag = DisposeBag()
    static let shared = RequestService()
    fileprivate init() {}
    func requestWith<T: Codable>(_ url: String,_ method: HTTPMethod, _ parameters: [String: Any]?,_ header: HTTPHeaders?, objectType: T.Type,  encoding: ParameterEncoding? = URLEncoding.default, _ animated : Bool = true,_ complete: @escaping ( _ model: Any?)->()) {
//        SHARE_APPLICATION_DELEGATE.window?.rootViewController?.view.addSubview(activityIndicatorView)
        
        if !Connectivity.isConnectedToInternet() {
            print("!Connectivity.isConnectedToInternet")
            
            if !isShowAlert {
                isShowAlert = true
                //                let alert = CommonAlert.instanceFromNib()
                //                alert.show(title: "Thông báo", desc: "Bạn đã mất kết nối với internet, vui lòng thử lại sau", dissmissTitle: "Đóng") {
                //                    isShowAlert = false
                //                }
            }
            
            complete(nil)
            
            
        } else {
            var headers = header
//            let token = Token()
//            if token.tokenExists {
//                headers = [
//                    "authorization": "Bearer \(token.token ?? "")",
//                    //                    "Content-Type": "x-www-form-urlencoded"
//                ]
//            }else {
//                headers = [
//                    //                    "Content-Type": "x-www-form-urlencoded"
//                ]
//            }
            
            AF.request(url, method: method, parameters: parameters, encoding: encoding! , headers: headers).validate(statusCode: 200..<300).responseJSON { response in
                print("URL: \(url)")
                print("METHOD: \(method.rawValue)" )
                print("PRAM: \(parameters ?? [:])")
                print("HEADER: \(headers ?? [:] )")
                print("STATUS_CODE: \(response.response?.statusCode ?? 0)")
                self.response(objectType, response) { (data) in
                    complete(data)
                }
            }
        }
    }
    
    func response<T: Codable>(_ objectType: T.Type,_ response: AFDataResponse<Any>,_ complete: @escaping (_ model: Any?)->()) {
        self.handleStatusCode(statusCode: response.response?.statusCode ?? 0)
        switch response.result {
        case let .success(value):
            print("RESPONE: \(value)")
            guard let json = value as? [String : Any] else {
                complete(nil)
                return
            }
            if let model = json.toCodableObject() as T? {
                complete(model)
            } else {
                complete(json)
            }
            
        case let .failure(error):
            print("RESPONE: \(error)")
            complete(nil)
        }
    }
    
    func upload<T: Codable>(_ url: String,_ method: HTTPMethod, _ parameters: [String: Any]?,_ header: HTTPHeaders?, objectType: T.Type, dataImages: [Dictionary<String, Any>]?, _ complete: @escaping CompleteHandleJSONCode) {
        var headers = header
//        let token = Token()
//        if token.tokenExists {
//            headers = [
//                "authorization": "Bearer \(token.token ?? "")",
//            ]
//        }
        
        AF.upload(multipartFormData: { multipartFormData in
            if let parameters = parameters {
                for (key, value) in parameters {
                    if let encode = "\(value)".data(using: String.Encoding.utf8) {
                        multipartFormData.append(encode, withName: key)
                    }
                }
            }
            if let dataImages = dataImages {
                for dict in dataImages {
                    guard let data: Data = dict["value"] as? Data, let key: String = dict["key"] as? String else {return}
                    multipartFormData.append(data, withName: key, fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                }
            }
        }, to: url).responseJSON { response in
            print("URL: \(url)")
            print("METHOD: \(method.rawValue)" )
            print("PRAM: \(parameters ?? [:])")
            print("HEADER: \(headers ?? [:] )")
            self.response(objectType, response) { (data) in
                complete(true, data, response.response?.statusCode)
            }
        }
    }
    
    func handleStatusCode(statusCode : Int?) {
//        switch statusCode {
//        case 401:
//            if Token().tokenExists {
//                Token().clear()
//
////                Utils.shared.gotoLogin()
//
//            }
//        default:
//            break
//        }
    }
    func uploadImage(url: String,
                     parameters: Dictionary<String, Any>?,
                     method: HTTPMethod,
                     header: HTTPHeaders?,
                     img: [UIImage]?,
                     urlIMG: String,
                     animated: Bool = false) -> Observable<JSON> {
        return Observable.create { (observe) -> Disposable in
            var headers = header
//            let token = Token()
//            if token.tokenExists {
//                headers = [
//                    "authorization": "Bearer \(token.token ?? "")",
//                ]
//            } else {
//                headers = [
//                    //                    "Content-Type": "x-www-form-urlencoded"
//                ]
//            }
            let request = AF.upload(multipartFormData: { multipartFormData in
                if let parameters = parameters {
                    for (key, value) in parameters {
                        if let encode = "\(value)".data(using: String.Encoding.utf8) {
                            multipartFormData.append(encode, withName: key)
                        }
                    }
                }
                if let img = img {
                    img.forEach { (i) in
                        multipartFormData.append(i.jpegData(compressionQuality: 0.1)!,
                                                 withName: urlIMG,
                                                 fileName: "\(Date().timeIntervalSince1970).png",
                                                 mimeType: "image/jpeg")
                    }
                }
            }, to: url,
            method: method ,
            headers: headers).responseJSON { response in
                self.handleStatusCode(statusCode: response.response?.statusCode ?? 0)
                switch response.result {
                case .success(let value):
                    let swiftJsonVar = JSON(value)
                    observe.onNext(swiftJsonVar)
                    observe.onCompleted()
                    print("------------ API RESPONSE ---------")
                    print("//Method: POST")
                    print("//Status Code: \(String(describing: response.response?.statusCode))")
                    print("//url")
                    print("//\(url)")
                    print("//Parameters")
                    print("\(String(describing: parameters))")
                    print("\(swiftJsonVar)")
                    print("-----------------------------------")
                case .failure(let error):
                    observe.onError(error)
                    observe.onCompleted()
                    print("Check res", response)
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    func APIUpload<T:Codable>(ofType type: T.Type,
                              url: String,
                              parameters: Dictionary<String, Any>?,
                              method: HTTPMethod,
                              header: HTTPHeaders?,
                              urlIMG: String,
                              animated: Bool = true,
                              img: [UIImage]? ) -> Observable<ApiResult<T, ErrorService>> {
        return Observable<ApiResult<T, ErrorService>>.create({ (observe) -> Disposable in
            self.uploadImage(url: url, parameters: parameters, method: method, header: header, img: img, urlIMG: urlIMG, animated: animated)
                .asObservable()
                .subscribe(onNext: { (msg) in
                    do {
                        if let jsonDic = msg.dictionaryObject {
                            if msg["result"].boolValue {
                                let data = try JSONSerialization.data(withJSONObject: jsonDic, options: .prettyPrinted)
                                let objec = try JSONDecoder().decode(T.self, from: data)
                                observe.onNext(.success(objec))
                                observe.onCompleted()
                            } else {
                                let data = try JSONSerialization.data(withJSONObject: jsonDic, options: .prettyPrinted)
                                let objec = try JSONDecoder().decode(ErrorService.self, from: data)
                                observe.onNext(.failure(objec))
                                observe.onCompleted()
                            }
                        }
                    } catch let err {
                        print(err.localizedDescription)
                        observe.onError(err)
                        observe.onCompleted()
                    }
                }, onError: { (err) in
                    print(err.localizedDescription)
                    observe.onError(err)
                    observe.onCompleted()
                }, onCompleted: {
                    print("Todo completed")
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        })
    }
    func getJSON(url: String,
                 parameters: Dictionary<String, Any>?,
                 method: HTTPMethod,
                 header: HTTPHeaders?,
                 animated : Bool = false) -> Observable<JSON>{
        return Observable.create({ (observe) -> Disposable in
            var headers = header
//            let token = Token()
//            if token.tokenExists {
//                headers = [
//                    "authorization": "Bearer \(token.token ?? "")",
//                ]
//            }else {
//                headers = []
//            }
            let request =  AF.request("SERVER + url",
                                      method: method,
                                      parameters: parameters,
                                      encoding: JSONEncoding.default,
                                      headers: headers).responseJSON { (response) in
                                        self.handleStatusCode(statusCode: response.response?.statusCode ?? 0)
                                        switch response.result {
                                       case .success(let value):
                                            let swiftJsonVar = JSON(value)
                                            print("------------ API RESPONSE ---------")
                                            print("//Method: \(method)")
                                            print("//Status Code: \(String(describing: response.response?.statusCode))")
                                            print("//url")
                                            print("//\("SERVER + url")")
                                            print("//Parameters")
                                            print("//\(String(describing: parameters))")
//                                        print("// Token: \(token.token ?? "")")
                                            print("//Result")
                                            print("\(swiftJsonVar)")
                                            print("--------------***END***------------------")
                                            observe.onNext(swiftJsonVar)
                                            observe.onCompleted()
                                        case .failure(let error):
                                            observe.onError(error)
                                            observe.onCompleted()
                                            print("Check res", response)
                                        }
                                      }
            return Disposables.create {
                request.cancel()
            }
        })
    }
    func APIData<T:Codable>(ofType type: T.Type, url: String, parameters: Dictionary<String, Any>?, method: HTTPMethod ) -> Observable<ApiResult<T, ErrorService>> {
        return Observable<ApiResult<T, ErrorService>>.create({ (observe) -> Disposable in
            self.getJSON(url: url, parameters: parameters, method: method, header: nil)
                .asObservable()
                .subscribe(onNext: { (msg) in
                    do {
                        if let jsonDic = msg.dictionaryObject {
                            if msg["result"].boolValue {
                                let data = try JSONSerialization.data(withJSONObject: jsonDic, options: .prettyPrinted)
                                let objec = try JSONDecoder().decode(T.self, from: data)
                                observe.onNext(.success(objec))
                                observe.onCompleted()
                            } else {
                                let data = try JSONSerialization.data(withJSONObject: jsonDic, options: .prettyPrinted)
                                let objec = try JSONDecoder().decode(ErrorService.self, from: data)
                                observe.onNext(.failure(objec))
                                observe.onCompleted()
                            }
                        }
                    } catch let err {
                        print(err.localizedDescription)
                        observe.onError(err)
                        observe.onCompleted()
                    }
                }, onError: { (err) in
                    print(err.localizedDescription)
                    observe.onError(err)
                    observe.onCompleted()
                }, onCompleted: {
                    print("Todo completed")
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        })
    }
}

extension Dictionary {
    func toCodableObject<T: Codable>() -> T? {
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            if let obj = try? decoder.decode(T.self, from: jsonData) {
                return obj
            }
            return nil
        }
        return nil
    }
    
}
enum ApiResult<Value, Error>{
    case success(Value)
    case failure(Error)
    
    init(value: Value){
        self = .success(value)
    }
    
    init(error: Error){
        self = .failure(error)
    }
}

struct ErrorGeneral: Codable {
    let result: Bool
    let error: ErrorService
}

// MARK: - Error
struct ErrorService: Codable {
    let result: Bool?
    let message: String?
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case result = "result"
    }
}
