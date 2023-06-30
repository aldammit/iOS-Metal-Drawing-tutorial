//
//  UIControl + Combine.swift
//  telegram-contest
//
//  Created by Bogdan Redkin on 11/10/2022.
//

import Foundation
import Combine
import UIKit

final class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private let control: Control

    init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(self.eventHandler), for: event)
    }

    func request(_ demand: Subscribers.Demand) { }

    func cancel() {
        self.subscriber = nil
    }

    @objc private func eventHandler() {
        _ = self.subscriber?.receive(self.control)
    }
}

struct UIControlPublisher<Control: UIControl>: Publisher {
    typealias Output = Control
    typealias Failure = Never

    let control: Control
    let controlEvents: UIControl.Event

    init(control: Control, events: UIControl.Event) {
        self.control = control
        self.controlEvents = events
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == UIControlPublisher.Failure, S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents)
        subscriber.receive(subscription: subscription)
    }
}

protocol CombineCompatible {}
extension UIControl: CombineCompatible {}
extension CombineCompatible where Self: UIControl {
    func publisher(for events: UIControl.Event) -> UIControlPublisher<UIControl> {
        return UIControlPublisher(control: self, events: events)
    }
}
