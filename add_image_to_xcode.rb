require 'xcodeproj'

project_path = 'Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'Garten_Simulation' }

# Find the main group
group = project.main_group.find_subpath('Garten_Simulation', true)

# Create file reference
file_path = 'Garten_Simulation/Splash_Screenicon.png'
# Check if file reference already exists
file_ref = group.files.find { |f| f.path == 'Splash_Screenicon.png' }
if file_ref.nil?
    file_ref = group.new_file('Splash_Screenicon.png')
end

# Add to resources build phase
resources_build_phase = target.resources_build_phase
unless resources_build_phase.files_references.include?(file_ref)
    build_file = resources_build_phase.add_file_reference(file_ref)
end

project.save
puts 'Successfully added Splash_Screenicon.png to Xcode project!'
