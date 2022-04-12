
//
//  
//  RecordingVC.swift
//  Capmix
//
//  Created by haiphan on 12/04/2022.
//
//
import UIKit
import RxCocoa
import RxSwift

class RecordingVC: BaseVC {
    
    // Add here outlets
    
    // Add here your view model
    private var viewModel: RecordingVM = RecordingVM()
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.setupBackButtonSingle()
    }
    
}
extension RecordingVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        title = "Recording"
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        
    }
}
