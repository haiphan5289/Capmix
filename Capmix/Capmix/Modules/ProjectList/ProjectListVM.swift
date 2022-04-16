
//
//  ___HEADERFILE___
//
import Foundation
import RxCocoa
import RxSwift
import EasyBaseAudio

class ProjectListVM {
    
    var recordings: BehaviorRelay<[URL]> = BehaviorRelay.init(value: [])
    
    private let disposeBag = DisposeBag()
    init() {
        self.getItemRecords()
    }
    
    func getItemRecords() {
        self.recordings.accept(AudioManage.shared.getItemsFolder(folder: ConstantApp.shared.folderRecording))
    }
}
