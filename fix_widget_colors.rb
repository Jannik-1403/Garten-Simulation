
require 'rubygems'
Gem.paths = { 'GEM_PATH' => '/Users/jannikschill/.gem/ruby/2.6.0:/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/gems/2.6.0' }
require 'xcodeproj'

project_path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find targets
widget_target = project.targets.find { |t| t.name == 'GartenWidgetExtension' }
main_target = project.targets.find { |t| t.name == 'Garten_Simulation' }

# Find AppColors.swift reference
file_ref = project.files.find { |f| f.path.include?('AppColors.swift') }

if file_ref && widget_target
  # Add to Widget if not already there
  if widget_target.source_build_phase.files.find { |f| f.file_ref == file_ref }.nil?
    widget_target.source_build_phase.add_file_reference(file_ref)
    puts "Added AppColors.swift to GartenWidgetExtension"
  else
    puts "AppColors.swift already in GartenWidgetExtension"
  end
end

project.save
puts "Done"
