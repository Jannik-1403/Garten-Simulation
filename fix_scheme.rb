require 'xcodeproj'

project_path = 'Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find targets
app_target = project.targets.find { |t| t.name == 'Garten_Simulation' }
test_target = project.targets.find { |t| t.name == 'Garten_SimulationUITests' }

# Set target dependency
test_target.add_dependency(app_target)

# Get the Xcode scheme
scheme_path = Xcodeproj::XCScheme.shared_data_dir(project_path) + 'Garten_SimulationUITests.xcscheme'
scheme = Xcodeproj::XCScheme.new(scheme_path)

# Add build action for the app target and test target
scheme.add_build_target(app_target)
scheme.add_build_target(test_target)

# Make sure they are built for testing
scheme.build_action.entries.each do |entry|
  entry.build_for_testing = true
  entry.build_for_running = true
end

scheme.save!
project.save
puts 'Scheme fixed!'
