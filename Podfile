use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

def shared_pods
    pod 'ReactiveCocoa', '4.2.1'
    pod 'Rex', '~> 0.11.0'
end

target 'TodaysReactiveMenu' do
    platform :ios, '9.0'
    
    shared_pods
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'PureLayout', '~> 3.0.1'
end

target 'TodaysReactiveMenuTests' do

end

target 'TodaysReactiveMenuWatch Extension' do
    platform :watchos, '2.0'
    
    shared_pods
end
