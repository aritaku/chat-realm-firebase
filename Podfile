platform :ios, '10.2'

target 'chat-firebase' do
  use_frameworks!

  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'JSQMessagesViewController'
  pod 'SlackTextViewController'
  pod 'RealmSwift'

  target 'chat-firebaseTests' do
    inherit! :search_paths
  end

  target 'chat-firebaseUITests' do
    inherit! :search_paths
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0.2'
        end
    end
end
