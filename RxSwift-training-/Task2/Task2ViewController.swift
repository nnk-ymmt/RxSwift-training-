//
//  Task2ViewController.swift
//  RxSwift-training-
//
//  Created by 山本ののか on 2020/12/23.
//

import RxCocoa
import RxSwift
import UIKit

final class Task2ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var label: UILabel!

    private let textFieldRelay = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        example1()
        example2()
        example3()
        example4()
        example5()
//        test1()
    }

    // Task1のObservableクラスはイベントを流すことはできるが、他からイベントを発生させることはできない
    // 以下の４つはイベントを受け取り、流すことができる
    // 全部自分で流したイベントを自分で受け取っている

    private func example1() {
        debugPrint("--- \(#function) 例1 ---")
        // 初期値がない
        let pubishSubject = PublishSubject<Int>()
        // イベントを受け取る処理
        pubishSubject.subscribe(onNext: { value in
            debugPrint("PublishSubject: \(value)")
        }).disposed(by: disposeBag)

        // イベントを流す
        pubishSubject.onNext(1)
        pubishSubject.onNext(2)
        // 好きなタイミングで何回でもイベントを流せる
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            pubishSubject.onNext(3)
        }
    }

    private func example2() {
        debugPrint("--- \(#function) 例2 ---")
        // 初期値がある
        let behaviorSubject = BehaviorSubject<Int>(value: 0)
        // イベントを受け取る処理
        behaviorSubject.subscribe(onNext: { value in
            debugPrint("BehaviorSubject: \(value)")
        }).disposed(by: disposeBag)

        // イベントを流す
        behaviorSubject.onNext(1)
        behaviorSubject.onNext(2)
        // 好きなタイミングで何回でもイベントを流せる
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            behaviorSubject.onNext(3)
        }
    }

    private func example3() {
        debugPrint("--- \(#function) 例3 ---")
        // 初期値がない
        // onNextがある
        // onCompletion, onErrorがない
        let publishRelay = PublishRelay<Int>()
        // イベントを受け取る処理
        publishRelay.subscribe(onNext: { value in
            debugPrint("PublishRelay: \(value)")
        }).disposed(by: disposeBag)

        // イベントを流す(他とメソッド名が違う)
        publishRelay.accept(1)
        publishRelay.accept(2)
        // 好きなタイミングで何回でもイベントを流せる
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            publishRelay.accept(3)
        }
    }

    private func example4() {
        debugPrint("--- \(#function) 例4 ---")
        // 初期値がある
        // onNextがある
        // onCompletion, onErrorがない
        let behaviorRelay = BehaviorRelay<Int>(value: 0)
        // イベントを受け取る処理
        behaviorRelay.subscribe(onNext: { value in
            debugPrint("BehaviorRelay: \(value)")
        }).disposed(by: disposeBag)

        // イベントを流す(他とメソッド名が違う)
        behaviorRelay.accept(1)
        behaviorRelay.accept(2)
        // 好きなタイミングで何回でもイベントを流せる
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            behaviorRelay.accept(3)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldRelay.accept(textField.text ?? "")
        return true
    }

    private func example5() {
        // textFieldのストリームから値を受け取りストリームに流す
        debugPrint("--- \(#function) 例5 ---")
        textFieldRelay.asObservable() // relayをobservableに変換する(無くても動くが明示しておいた方が安全)
            .subscribeOn(MainScheduler.instance) // 問1で使うから書くがsubscribeをメインスレッドで処理する
            .subscribe(onNext: { str in
                debugPrint(str)
            }).disposed(by: disposeBag)
    }

    private func test1() {
        // textFieldのストリームから受け取った値をlabelのtextにする
        debugPrint("--- \(#function) 問1 ---")
        textFieldRelay.asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { str in
                self.label.text = str
            }).disposed(by: disposeBag)

        // 解答
        textFieldRelay
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] str in
                self?.label.text = str
            }).disposed(by: disposeBag)
    }
}
