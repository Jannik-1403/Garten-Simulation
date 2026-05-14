
require 'rubygems'
Gem.paths = { 'GEM_PATH' => '/Users/jannikschill/.gem/ruby/2.6.0:/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/gems/2.6.0' }
require 'xcodeproj'

project_path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Intents group
main_group = project.main_group['Garten_Simulation']
intents_group = main_group['Intents'] || main_group.new_group('Intents')

files_to_add = ['PlantEntity.swift', 'WaterPlantIntent.swift', 'GartenShortcuts.swift']
targets_to_update = ['Garten_Simulation', 'GartenWidgetExtension']

files_to_add.each do |file_name|
  # Check if file ref exists in group
  file_ref = intents_group.files.find { |f| f.path == file_name || f.path == "Intents/#{file_name}" }
  if file_ref.nil?
    # Try to find it in the group without creating a new reference if it's already there
    file_ref = intents_group.new_file(file_name)
    puts "Created new file reference for #{file_name}"
  end

  targets_to_update.each do |target_name|
    target = project.targets.find { |t| t.name == target_name }
    next if target.nil?

    # Check if already in build phase
    build_phase = target.source_build_phase
    existing = build_phase.files.find { |f| f.file_ref == file_ref }
    if existing.nil?
      build_phase.add_file_reference(file_ref)
      puts "Added #{file_name} to target #{target_name}"
    else
      puts "#{file_name} already in target #{target_name}"
    end
  end
end

project.save
puts "Project updated successfully"
