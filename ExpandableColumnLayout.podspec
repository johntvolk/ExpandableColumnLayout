Pod::Spec.new do |s|
  s.name             = "ExpandableColumnLayout"
  s.version          = "1.0.0"
  s.summary          = "A custom UICollectionViewLayout that provides a flexible column-based layout with optional expandable drawer functionality."
  s.description      = <<-DESC
                       * Arbitrary column count per section
                       * Specifiy unit-height or exact height per item
                       * Expand or contract sections via attractive drawer-like animation
                       DESC
  s.homepage         = "https://github.com/johntvolk/ExpandableColumnLayout"
  s.license          = 'MIT'
  s.author           = { "John Volk" => "john.t.volk@gmail.com" }
  s.source           = { :git => "https://github.com/johntvolk/ExpandableColumnLayout.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

end
