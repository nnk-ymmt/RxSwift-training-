//
//  Task3ViewController.swift
//  RxSwift-training-
//
//  Created by 山本ののか on 2020/12/24.
//

import RxCocoa
import RxSwift
import UIKit

final class Task3ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet private weak var textField1: UITextField!
    @IBOutlet private weak var textField2: UITextField!
    @IBOutlet private weak var label: UILabel!

    private let disposeBag = DisposeBag()
    private let textField1Relay = BehaviorRelay<String>(value: "")
    private let textField2Relay = BehaviorRelay<String>(value: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        example1()
        test1()
    }

    private func example1() {
        do {
            // (例1) 複数のストリームを合成
            // イメージ的にはor
            // 何かがきたら流れる
            debugPrint("--- \(#function) 例1 ---")
            let stream1 = Observable.just(1)
            let stream2 = Observable.just(2)
            Observable.merge(stream1, stream2).subscribe(onNext: { value in
                debugPrint(value)
            }).disposed(by: disposeBag)
        }

        do {
            // (例2) 複数のストリームの最後に流れたイベントを合体
            // aとbのstreamが(a,b)とひとつのtuppleになる
            debugPrint("--- \(#function) 例2 ---")
            let stream1 = Observable.just(1)
            let stream2 = Observable.just(2)
            Observable.combineLatest(stream1, stream2).subscribe(onNext: { value in
                debugPrint(value)
            }).disposed(by: disposeBag)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textField1 {
            textField1Relay.accept(textField.text ?? "")
        } else {
            textField2Relay.accept(textField.text ?? "")
        }
        return true
    }

    private func test1() {
        // 2つのtextFieldの文字を合成してlabelに表示する
        // textField1.textが "あいうえお", textField2.textが "かきくけこ"
        // であれば、labelに "あいうえおかきくけこ"が表示される
        debugPrint("--- \(#function) 問1 ---")
        Observable.combineLatest(textField1Relay, textField2Relay).subscribe(onNext: { value in
            self.label.text = value.0 + value.1
        }).disposed(by: disposeBag)

        // 解答
        Observable.combineLatest(textField1Relay.asObservable(), textField2Relay.asObservable())
            .map({ str1, str2 -> String in
                str1 + str2
            })
            .subscribeOn(MainScheduler.instance)
            .subscribe { [weak self] str in
                self?.label.text = str
            }.disposed(by: disposeBag)
    }
}
