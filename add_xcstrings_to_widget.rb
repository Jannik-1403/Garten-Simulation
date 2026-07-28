require 'xcodeproj'

project_path = 'Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the widget target
widget_target = project.targets.find { |t| t.name == 'GartenWidgetExtension' }
if widget_target.nil?
  puts "Widget target not found"
  exit 1
end

# Find or create a group for shared resources
group = project.main_group.find_subpath('GartenWidget', true)
file_path = 'Garten_Simulation/Localizable.xcstrings'

# Check if file reference already exists
file_ref = project.files.find { |f| f.path == file_path || f.path == 'Localizable.xcstrings' && f.real_path.to_s.end_with?('Localizable.xcstrings') }

if file_ref.nil?
  puts "Creating file reference for Localizable.xcstrings"
  file_ref = group.new_reference('../Garten_Simulation/Localizable.xcstrings')
end

# Check if it's already in the build phase
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
