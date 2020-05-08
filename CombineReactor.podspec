Pod::Spec.new do |s|
  s.name = "CombineReactor"
  s.version = "0.1"
  s.summary = "A wrapper for Combine, inspired by ReactorKit"
  s.homepage = "http://ilendemli.info"
  s.license = {
    :type => "MIT",
    :file => "LICENSE"
  }
  s.author = {
    "Muhammet Ilendemli" => "ilendemli@live.at"
  }
  s.source = {
    :git => "https://github.com/ilendemli/CombineReactor.git",
    :tag => s.version.to_s
  }

  s.swift_version = "5.0"
  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files = "CombineReactor/CombineReactor/Core/**/*.swift"
    ss.frameworks = "Foundation", "Combine"
    ss.dependency "WeakMapTable", "~> 1.1"
  end

  s.subspec "Runtime" do |ss|
    ss.source_files = "CombineReactor/CombineReactor/Runtime/**/*.{h,m}"
    ss.dependency "CombineReactor/Core"
  end

  s.test_spec "Tests" do |ss|
    ss.source_files = "CombineReactor/CombineReactorTests/**/*.swift"
    ss.dependency "CombineReactor/Core"
    ss.platforms = {
        :ios => "13.0",
        :osx => "10.15",
        :tvos => "13.0"
    }
  end

  s.ios.deployment_target = "13.0"
  s.osx.deployment_target = "10.15"
  s.tvos.deployment_target = "13.0"
  s.watchos.deployment_target = "6.0"
end
