require 'rubygems'
Gem.paths = { 'GEM_PATH' => '/Users/jannikschill/.gem/ruby/2.6.0:/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/gems/2.6.0' }
require 'xcodeproj'

project_path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main group (Garten_Simulation)
main_group = project.main_group.children.find { |group| group.display_name == 'Garten_Simulation' || group.path == 'Garten_Simulation' }

if main_group.nil?
  puts "Could not find main group"
  exit 1
end

# Check if file already exists
existing_file = main_group.files.find { |f| f.path == 'LaunchScreen.storyboard' }
if existing_file
  puts "File already in project"
  exit 0
end

file_ref = main_group.new_file('LaunchScreen.storyboard')

# Add it to the main target's resources build phase
target = project.targets.find { |t| t.name == 'Garten_Simulation' }
resources_phase = target.resources_build_phase
resources_phase.add_file_reference(file_ref)

project.save
puts "Successfully added LaunchScreen.storyboard to project"
