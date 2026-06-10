require 'xcodeproj'
project = Xcodeproj::Project.open('Garten_Simulation.xcodeproj')
widget_target = project.targets.find { |t| t.name == 'GartenWidgetExtension' }

# Find or create file reference for Garten_Simulation/Models/GardenActivityAttributes.swift
main_group = project.main_group
file_path = 'Garten_Simulation/Models/GardenActivityAttributes.swift'

# We don't need to put it in a specific group if we just want it to compile. We can just add it to the project root group.
file_ref = main_group.files.find { |f| f.path == file_path } || main_group.new_reference(file_path)

unless widget_target.source_build_phase.files_references.include?(file_ref)
  widget_target.source_build_phase.add_file_reference(file_ref)
  puts "Added to Widget Target"
end

project.save
puts "Saved"
