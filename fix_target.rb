require 'xcodeproj'

project_path = 'Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find UITest target
target = project.targets.find { |t| t.name == 'Garten_SimulationUITests' }

# Find SnapshotHelper.swift and add to target
file_ref = project.files.find { |f| f.path == 'SnapshotHelper.swift' }

if file_ref.nil?
  puts "SnapshotHelper.swift not found in project. Adding it..."
  # Create a file reference at the root or within the group
  # If Garten_SimulationUITests group exists, use it, else root
  group = project.main_group
  file_ref = group.new_file('SnapshotHelper.swift')
end

# Add file reference to target's source build phase if not already there
unless target.source_build_phase.files_references.include?(file_ref)
  target.source_build_phase.add_file_reference(file_ref, true)
  puts "Added SnapshotHelper.swift to target"
else
  puts "SnapshotHelper.swift is already in target"
end

project.save
puts 'Project saved successfully'
