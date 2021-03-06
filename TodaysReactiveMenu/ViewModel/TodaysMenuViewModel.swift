//
//  TodaysMenuViewModel.swift
//  TodaysReactiveMenu
//
//  Created by Steffen Damtoft Sommer on 25/05/15.
//  Copyright (c) 2015 steffendsommer. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import Result


struct TodaysMenuViewModel: MVVMViewModelResource {
    
    private let menuAPI: RemoteResource
    private let menuNotReadyMsg     = "The chef is working hard on getting Today's Menu ready. Please come back later."
    private let fetchMenuErrorMsg   = "Something went wrong in the kitchen. Please come back later."
    
    let isActive                    = MutableProperty<Bool>(false)
    let headline                    = ConstantProperty<String>("Today's Menu")
    let subHeadline                 = ConstantProperty<String>("at\nUnwire")
    private let menu                = MutableProperty<Menu?>(nil)
    private let wMainCourse         = MutableProperty("")
    var mainCourse                  : AnyProperty<String>!
    let logo                        = ConstantProperty<UIImage?>(UIImage(named: "Logo"))
    let sides                       = MutableProperty<String>("")
    let cake                        = ConstantProperty<String>("CAKE DAY")
    let isCakeServedToday           = MutableProperty<Bool>(true)
    let shouldHideMenu              = MutableProperty<Bool>(true)
    var likeAction                  = MutableProperty<CocoaAction?>(nil)
    
    
    // MARK: Object Life Cycle -
    
    init(menuAPI: RemoteResource) {
        self.menuAPI = menuAPI
        
        self.mainCourse = AnyProperty(self.wMainCourse)
        
        // Setup RAC bindings.
        self.setupBindings()
    }

    
    // MARK: RAC Bindings -
    
    func setupBindings() {
        
        self.isActive.producer
            .filter { $0 }
            .mapError { _ in
                return MenuDataManager.FetchMenuError.UnknownError
            }
            .flatMap(.Latest) { _ in
                return MenuDataManager.fetchTodaysMenuFromCacheOrRemote(self.menuAPI)
            }
            .startWithSignal { signal, disposable in
            
                // Until https://github.com/ReactiveCocoa/ReactiveCocoa/issues/2728 gets fixed
                // a more imperative approach is used.
                signal.observe { event in
                    switch event {
                        case let .Next(fetchedMenu):
                            self.menu.value = fetchedMenu
                        case .Failed(_):
                            self.wMainCourse.value = self.fetchMenuErrorMsg
                        default:
                            break
                    }
                }
            }

        // Make sure, we're only showing the menu when it's actually the menu of today.
        self.shouldHideMenu <~ self.menu.signal
            .ignoreNil()
            .map { menu in
                !menu.isTodaysMenu()
            }

        // Make sure to display some informative messages if the menu cannot be fetched.
        self.wMainCourse <~ self.menu.signal
            .ignoreNil()
            .map { fetchedMenu in
                if (fetchedMenu.isTodaysMenu()) {
                    return fetchedMenu.mainCourse
                } else {
                    return self.menuNotReadyMsg
                }
            }
            .flatMapError { _ in
                return SignalProducer<String, NoError>(value: self.fetchMenuErrorMsg)
            }

        self.sides <~ self.menu.signal
            .ignoreNil()
            .map { menu in
                menu.sides
            }
        
        // Handle the showing of the cake banner.
        let anyCake = self.menu.signal
            .ignoreNil()
            .map { menu in
                menu.cake
            }

        self.isCakeServedToday <~ combineLatest(self.shouldHideMenu.signal, anyCake)
            .map { shouldHideMenu, cakeToday in
                shouldHideMenu || !cakeToday
            }

//        self.likeAction <~ self.menu.signal
//            .ignoreNil()
//            .map { menu in
//                return CocoaAction(menu.like(), input: ())
//            }
    }

}
