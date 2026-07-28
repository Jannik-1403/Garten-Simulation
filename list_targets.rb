require 'xcodeproj'
project = Xcodeproj::Project.open('Garten_Simulation.xcodeproj')
puts "Targets:"
project.targets.each { |t| puts t.name }
puts "Looking for Localizable.xcstrings:"
file = project.files.find { |f| f.path && f.path.include?('Localizable.xcstrings') }
puts file ? file.path : "Not found in project.files"

file2 = project.files.find { |f| f.name && f.name.include?('Localizable.xcstrings') }
puts file2 ? file2.name : "Not found by name"
