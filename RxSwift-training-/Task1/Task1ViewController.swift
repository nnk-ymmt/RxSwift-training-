//
//  Task1ViewController.swift
//  RxSwift-training-
//
//  Created by 山本ののか on 2020/12/21.
//

import RxSwift
import UIKit

final class Task1ViewController: UIViewController {

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        example1()
        test1()
        example2()
        test2()
    }

    private func example1() {
        do {
            // (例1) イベントをストリームに流してコンソールに表示
            debugPrint("--- \(#function) 例1 ---")
            Observable.of("Hello World").subscribe(onNext: { value in
                debugPrint(value)
            }).disposed(by: disposeBag)
        }

        do {
            // (例2) イベント(1)をストリームに流して2倍にしてコンソールに表示
            debugPrint("--- \(#function) 例2 ---")
            Observable.of(1).map { value -> Int in
                value * 2
            }.subscribe(onNext: { value in
                debugPrint(value)
            }).disposed(by: disposeBag)
        }

        do {
            // (例3) イベント(0~4)をストリームに流してコンソールに表示
            debugPrint("--- \(#function) 例3 ---")
            Observable.of(0, 1, 2, 3, 4).subscribe(onNext: { value in
                debugPrint(value)
            }).disposed(by: disposeBag)
        }
    }

    private func test1() {
        // (問1) イベント(0~4)をストリームに流して、2倍して、5以下をコンソールに表示
        debugPrint("--- \(#function) 問1 ----")
        Observable.from([0, 1, 2, 3, 4]).map { value -> Int in
            value * 2
        }.filter { value -> Bool in
            value < 5
        }.subscribe(onNext: { value in
            debugPrint(value)
        }).disposed(by: disposeBag)
    }

    private func example2() {
        do {
            // (例1) 完了イベントをストリームに流し、全てのストリームが流れ終わるとcompletion
            debugPrint("--- \(#function) 例1 ---")
            let observable = Observable.from([0,1,2,3,4])
            observable.subscribe(onNext: { value in
                debugPrint("success: \(value)")
            }, onCompleted: {
                debugPrint("completion")
            }).disposed(by: disposeBag)
        }

        do {
            // (例2) 例外イベントをストリームに流す
            debugPrint("--- \(#function) 例2 ---")
            let observable = Observable.from([0,1,2,3,4,5,6])
            observable.do(onNext: { value in // doメソッドはストリームが流れたら処理を挟む
                if value == 4 { throw NSError.init(domain: "error", code: 0, userInfo: nil) }
            }).subscribe(onNext: { value in
                debugPrint("success: \(value)")
            }, onError: { error in
                debugPrint("error: \(error)")
            }, onCompleted: {
                debugPrint("completion")
            }).disposed(by: disposeBag)
        }
    }

    private func test2() {
        // (問2) ランダムな数値をストリームに流して、表示してcompletionかerrorにする
        debugPrint("--- \(#function) 問2 ---")
        // 1度だけストリームを流して終了させる処理を10回テスト
        for _ in 0...10 {
            let observable = Observable.of(Int.random(in: 0...10))
            observable.do(onNext: { value in
                if value % 2 == 0 {
                    throw NSError.init(domain: "error", code: 0, userInfo: nil)
                }
            }).subscribe(onNext: { value in
                debugPrint("success: \(value)")
            }, onError: { error in
                debugPrint("error: \(error)")
            }, onCompleted: {
                debugPrint("completion")
            }).disposed(by: disposeBag)
        }
    }
}
