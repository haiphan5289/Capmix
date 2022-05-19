
//
//  ___HEADERFILE___
//
import Foundation
import RxCocoa
import RxSwift
import EasyBaseAudio

class ProjectListVM {
    
    var recordings: BehaviorRelay<[URL]> = BehaviorRelay.init(value: [])
    var mymusic: BehaviorRelay<[URL]> = BehaviorRelay.init(value: [])
    var myProjects: BehaviorRelay<[URL]> = BehaviorRelay.init(value: [])
    var imports: BehaviorRelay<[URL]> = BehaviorRelay.init(value: [])
    @VariableReplay var listSound: [SoundModel] = []
    
    private let disposeBag = DisposeBag()
    init() {
        self.getItemRecords()
        self.getItemMyMusic()
        self.getItemImports()
//        self.getListSound()
    }
    
    func getItemRecords() {
        self.recordings.accept(AudioManage.shared.getItemsFolder(folder: ConstantApp.shared.folderRecording))
    }
    
    func getItemMyMusic() {
        self.mymusic.accept(AudioManage.shared.getItemsFolder(folder: ConstantApp.shared.folderProject))
    }
    
    func getItemImports() {
        self.imports.accept(AudioManage.shared.getItemsFolder(folder: ConstantApp.shared.folderImport))
    }
    
    private func getListSound() {
        RequestService.shared.APIData(ofType: OptionalMessageDTO<[SoundModel]>.self,
                                      url: APILink.listSound.rawValue,
                                      parameters: nil,
                                      method: .get)
            .bind { (result) in
                switch result {
                case .success(let value):
                    guard let data = value.data, let model = data else {
                        return
                    }
                    self.listSound = model
                case .failure( _): break
                }}.disposed(by: disposeBag)
    }
}
