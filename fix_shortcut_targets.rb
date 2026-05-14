
require 'rubygems'
Gem.paths = { 'GEM_PATH' => '/Users/jannikschill/.gem/ruby/2.6.0:/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/gems/2.6.0' }
require 'xcodeproj'

project_path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Widget target
widget_target = project.targets.find { |t| t.name == 'GartenWidgetExtension' }
main_target = project.targets.find { |t| t.name == 'Garten_Simulation' }

if widget_target
  # Find GartenShortcuts.swift reference
  file_ref = project.files.find { |f| f.path.include?('GartenShortcuts.swift') }
  if file_ref
    # Remove from Widget
    widget_target.source_build_phase.remove_file_reference(file_ref)
    puts "Removed GartenShortcuts.swift from GartenWidgetExtension"
    
    # Ensure it's in Main Target
    if main_target.source_build_phase.files.find { |f| f.file_ref == file_ref }.nil?
      main_target.source_build_phase.add_file_reference(file_ref)
      puts "Added GartenShortcuts.swift to Garten_Simulation"
    end
  end
end

project.save
puts "Done"
