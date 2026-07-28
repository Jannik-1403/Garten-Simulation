require 'xcodeproj'

project_path = 'Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

widget_target = project.targets.find { |t| t.name == 'GartenWidgetExtension' }

file_path = 'Garten_Simulation/Localizable.xcstrings'

# Check if file reference already exists in project.files
file_ref = project.files.find { |f| f.path == file_path || f.path == 'Localizable.xcstrings' && f.real_path.to_s.end_with?('Localizable.xcstrings') }

if file_ref.nil?
  puts "Creating file reference for Localizable.xcstrings"
  # Add file reference directly to project
  file_ref = project.new_file(file_path)
end

resources_phase = widget_target.resources_build_phase
build_file = resources_phase.files.find { |bf| bf.file_ref == file_ref }

if build_file.nil?
  puts "Adding Localizable.xcstrings to GartenWidgetExtension resources"
  resources_phase.add_file_reference(file_ref)
  project.save
  puts "Done!"
else
  puts "Localizable.xcstrings is already in the Widget target."
end
