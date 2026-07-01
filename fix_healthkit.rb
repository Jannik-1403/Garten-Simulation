require 'xcodeproj'

project_path = 'Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  if target.name == 'Garten_Simulation'
    # Find and remove bad HealthKit references
    target.frameworks_build_phase.files.each do |file|
      if file.file_ref && file.file_ref.name == 'HealthKit.framework'
        target.frameworks_build_phase.remove_build_file(file)
      end
    end
  end
end

# Remove from frameworks group
project.frameworks_group.children.each do |child|
  if child.name == 'HealthKit.framework'
    child.remove_from_project
  end
end

project.save
puts "Fixed HealthKit.framework reference"
