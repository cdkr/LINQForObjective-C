
Pod::Spec.new do |s|

  s.name         = "LINQForObjective-C"
  s.version      = "0.0.1"
  s.summary      = "Bringing LINQ-style APIs to Objective-C. Helping querying and multiplating collections."
  s.description  = <<-DESC
                   Bringing LINQ-style APIs to Objective-C. 
                   Helping querying and multiplating collections.
                   DESC
            
  s.license      = "MIT"

  s.author             = { "Yao Long" => "yaolongscope@gmail.com" }

  s.source       = { :git => "http://github.com/cdkr/LINQForObjective-C.git", :tag => "0.0.1" }

  s.source_files  = "OCLinq.{h,m}"

end
