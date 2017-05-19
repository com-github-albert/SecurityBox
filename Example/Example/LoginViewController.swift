//
//  LoginViewController.swift
//  Example
//
//  Created by JT Ma on 19/05/2017.
//  Copyright © 2017 JT Ma. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

let minimalUsernameLength = 5;
let minimalPasswordLength = 5;

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        let usernameValid = usernameTextField.rx.text.orEmpty
            .map { $0.characters.count >= minimalUsernameLength }
            .shareReplay(1) // without this map would be executed once for each binding, rx is stateless by default
        
        let passwordValid = passwordTextField.rx.text.orEmpty
            .map { $0.characters.count >= minimalPasswordLength }
            .shareReplay(1)
        
        usernameValid
            .bind(to: passwordTextField.rx.isEnabled)
            .disposed(by: disposeBag)
        
        passwordValid
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.performSegue(withIdentifier: "DismissLoginView", sender: self)
            })
            .disposed(by: disposeBag)
        
    }
}
