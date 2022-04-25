
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
    
    private let disposeBag = DisposeBag()
    init() {
        self.getItemRecords()
        self.getItemMyMusic()
    }
    
    func getItemRecords() {
        self.recordings.accept(AudioManage.shared.getItemsFolder(folder: ConstantApp.shared.folderRecording))
    }
    
    func getItemMyMusic() {
        self.mymusic.accept(AudioManage.shared.getItemsFolder(folder: ConstantApp.shared.folderProject))
    }
}
