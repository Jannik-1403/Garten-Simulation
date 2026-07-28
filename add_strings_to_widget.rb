require 'xcodeproj'
project_path = 'Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)
widget_target = project.targets.find { |t| t.name == 'GartenWidgetExtension' }
file_ref = project.files.find { |f| f.path == 'Garten_Simulation/Localizable.xcstrings' } || project.files.find { |f| f.path.include?('Localizable.xcstrings') }

if widget_target && file_ref
  resources_build_phase = widget_target.resources_build_phase
  unless resources_build_phase.files_references.include?(file_ref)
    resources_build_phase.add_file_reference(file_ref)
    project.save
    puts "Added Localizable.xcstrings to GartenWidgetExtension"
  else
    puts "Already there"
  end
else
  puts "Target or file not found"
end
