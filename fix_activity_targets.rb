require 'xcodeproj'
project_path = 'Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

app_target = project.targets.find { |t| t.name == 'Garten_Simulation' }
widget_target = project.targets.find { |t| t.name == 'GartenWidgetExtension' }

# Add GardenActivityAttributes.swift
attributes_path = 'Garten_Simulation/Models/GardenActivityAttributes.swift'
models_group = project.main_group.find_subpath(File.join('Garten_Simulation', 'Models'), true)
attr_ref = models_group.find_file_by_path('GardenActivityAttributes.swift')
unless attr_ref
  attr_ref = models_group.new_file('GardenActivityAttributes.swift')
end

# Add to App target
unless app_target.source_build_phase.files_references.include?(attr_ref)
  app_target.add_file_references([attr_ref])
  puts "Added Attributes to App Target"
end

# Add to Widget target
unless widget_target.source_build_phase.files_references.include?(attr_ref)
  widget_target.add_file_references([attr_ref])
  puts "Added Attributes to Widget Target"
end

# Add GardenLiveActivity.swift to Widget target
live_activity_path = 'GartenWidget/GardenLiveActivity.swift'
widget_group = project.main_group.find_subpath('GartenWidget', true)
activity_ref = widget_group.find_file_by_path('GardenLiveActivity.swift')
unless activity_ref
  activity_ref = widget_group.new_file('GardenLiveActivity.swift')
end

unless widget_target.source_build_phase.files_references.include?(activity_ref)
  widget_target.add_file_references([activity_ref])
  puts "Added LiveActivity to Widget Target"
end

project.save
puts "Project saved!"
