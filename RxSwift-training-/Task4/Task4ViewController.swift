//
//  Task4ViewController.swift
//  RxSwift-training-
//
//  Created by 山本ののか on 2020/12/25.
//

import NSObject_Rx
import RxCocoa
import RxGesture
import RxSwift
import UIKit

final class Task4ViewController: UIViewController, HasDisposeBag {

    @IBOutlet private weak var view1: UIView!
    @IBOutlet private weak var button1: UIButton!
    @IBOutlet private weak var textField1: UITextField!

    @IBOutlet private weak var view2: UIView!
    @IBOutlet private weak var button2: UIButton!
    @IBOutlet private weak var textField2: UITextField!

    @IBOutlet private weak var redTextField: UITextField!
    @IBOutlet private weak var greenTextField: UITextField!
    @IBOutlet private weak var blueTextField: UITextField!
    @IBOutlet private weak var view3: UIView!

    // HasDisposeBagに準拠しているといらなくなる
    // private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        example1()
        example2()
    }

    private func example1() {
        do {
            // view1のタップ RxGestureを使う
            view1.rx.tapGesture().when(.recognized).subscribe(onNext: { _ in
                debugPrint("view1 tapped")
            }).disposed(by: disposeBag)
        }

        do {
            button1.rx.tap.subscribe(onNext: { _ in
                debugPrint("button1 tapped")
            }).disposed(by: disposeBag)
        }

        do {
            textField1.rx.controlEvent(.editingChanged).subscribe(onNext: { _ in
                debugPrint("textField1 .editingChanged")
            }).disposed(by: disposeBag)
        }
    }

    private func example2() {
        // textField2の値が変わる度に流れるストリーム
        let changeTextFieldObservable = textField2.rx.controlEvent(.editingChanged)
            .map { [weak self] _ -> UIColor in
                guard let text = self?.textField2.text else { return UIColor.black }
                // textfield2のテキストに合わせてUIColorを生成してイベントとする
                var white = CGFloat(Double(text) ?? 0.0)
                white = min(1.0, max(0.0, white / 255)) // 0~1の間になる
                let color = UIColor.init(white: white, alpha: 1.0)
                return color
            }

        // button2をタップしたときのストリーム
        let tapButtonObservable = button2.rx.tap
            .subscribeOn(MainScheduler.instance) // メインスレッドで処理(このあとviewを更新するから)
            .do(onNext: { [weak self] _ in // イベントがきたらtextField2を初期化する
                self?.textField2.text = ""
            }).map { _ in // mapで返す値をUIColor.blackに変換
                UIColor.black
            }

        // 2つのストリームをmerge
        let changeColorObservable = Observable.merge(tapButtonObservable, changeTextFieldObservable)

        // changeColorObservableのイベントを購買してview2.rx.backgroundColor渡す
        changeColorObservable.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] color in
            self?.view2.backgroundColor = color
        }).disposed(by: disposeBag)
        // イベントの値を直接渡す場合はbindでこう渡した方が直感的
//        changeColorObservable.subscribeOn(MainScheduler.instance).bind(to: view2.rx.backgroundColor).disposed(by: disposeBag)
    }

    private let redTextFieldRelay = BehaviorRelay<String>(value: "")
    private let greenTextFieldRelay = BehaviorRelay<String>(value: "")
    private let blueTextFieldRelay = BehaviorRelay<String>(value: "")

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case redTextField:
            redTextFieldRelay.accept(textField.text ?? "")
        case greenTextField:
            greenTextFieldRelay.accept(textField.text ?? "")
        case blueTextField:
            blueTextFieldRelay.accept(textField.text ?? "")
        default:
            break
        }
        return true
    }

    private func test() {
        // (問1) ３つのテキストフィールドの値が変わったらイベントを流して、view3のbackgroundColorの色を変える
        let redTextFieldObservable = redTextField.rx.controlEvent(.editingChanged)
            .map{ [weak self] _ -> UIColor in
                guard let text = self?.redTextField.text else { return UIColor.red }
                var red = CGFloat(Double(text) ?? 0.0)
                red = min(1.0, max(0.0, red / 255))
                let color = UIColor.init(red:  red, green: 0, blue: 0, alpha: 1.0)
                return color
            }

        let greenTextFieldObservable = greenTextField.rx.controlEvent(.editingChanged)
            .map{ [weak self] _ -> UIColor in
                guard let text = self?.greenTextField.text else { return UIColor.green }
                var green = CGFloat(Double(text) ?? 0.0)
                green = min(1.0, max(0.0, green / 255))
                let color = UIColor.init(red:  0, green: green, blue: 0, alpha: 1.0)
                return color
            }

        let blueTextFieldObservable = blueTextField.rx.controlEvent(.editingChanged)
            .map{ [weak self] _ -> UIColor in
                guard let text = self?.blueTextField.text else { return UIColor.blue }
                var blue = CGFloat(Double(text) ?? 0.0)
                blue = min(1.0, max(0.0, blue / 255))
                let color = UIColor.init(red:  0, green: 0, blue: blue, alpha: 1.0)
                return color
            }

        let changeColorObservable = Observable.merge(redTextFieldObservable, greenTextFieldObservable, blueTextFieldObservable)
        changeColorObservable.subscribeOn(MainScheduler.instance).subscribe(onNext: { [weak self] color in
            self?.view3.backgroundColor = color
        }).disposed(by: disposeBag)
//        let changeColorObservable = Observable.merge(redTextFieldRelay, greenTextFieldRelay, blueTextFieldRelay)
//        changeColorObservable.subscribe(onNext: { color in
//            self.view3.backgroundColor = color
//        }).disposed(by: disposeBag)
    }
}
