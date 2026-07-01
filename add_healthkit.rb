require 'xcodeproj'

project_path = 'Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  if target.name == 'Garten_Simulation'
    # Enable HealthKit capability
    attributes = project.root_object.attributes['TargetAttributes'] || {}
    target_attributes = attributes[target.uuid] || {}
    target_attributes['SystemCapabilities'] ||= {}
    target_attributes['SystemCapabilities']['com.apple.HealthKit'] = { 'enabled' => '1' }
    attributes[target.uuid] = target_attributes
    project.root_object.attributes['TargetAttributes'] = attributes
    
    # Add HealthKit framework
    healthkit_ref = project.frameworks_group.new_reference('System/Library/Frameworks/HealthKit.framework')
    unless target.frameworks_build_phase.files.map(&:file_ref).include?(healthkit_ref)
        target.frameworks_build_phase.add_file_reference(healthkit_ref)
    end
  end
end

project.save
puts "HealthKit capability added to project.pbxproj"
