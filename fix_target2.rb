require 'xcodeproj'
project = Xcodeproj::Project.open('Garten_Simulation.xcodeproj')
widget_target = project.targets.find { |t| t.name == 'GartenWidgetExtension' }

main_group = project.main_group
file_path = 'GartenWidget/GardenLiveActivity.swift'
file_ref = main_group.files.find { |f| f.path == file_path } || main_group.new_reference(file_path)

unless widget_target.source_build_phase.files_references.include?(file_ref)
  widget_target.source_build_phase.add_file_reference(file_ref)
  puts "Added GardenLiveActivity to Widget Target"
end

project.save
puts "Saved"
