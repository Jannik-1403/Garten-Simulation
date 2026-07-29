require 'xcodeproj'

project_path = 'Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find target (usually the first one)
target = project.targets.first

# Add files
files = [
    'Garten_Simulation/Models/GoalModels.swift',
    'Garten_Simulation/Stores/GoalStore.swift'
]

files.each do |file_path|
    # Find group based on directory
    group_name = File.dirname(file_path).split('/').last
    group = project.main_group['Garten_Simulation'][group_name]
    
    # Add file to group
    file_ref = group.new_reference(File.basename(file_path))
    
    # Add file reference to target's source build phase
    target.source_build_phase.add_file_reference(file_ref, true)
    puts "Added #{file_path} to target"
end

project.save
puts 'Project saved successfully'
