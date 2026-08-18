require 'xcodeproj'
require 'fileutils'

project_path = 'Garten_Simulation.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Check if InfoPlist.strings already exists in the project
main_group = project.main_group.find_subpath('Garten_Simulation', false)

# Create a VariantGroup for InfoPlist.strings if it doesn't exist
variant_group = main_group.children.find { |c| c.name == 'InfoPlist.strings' && c.class == Xcodeproj::Project::Object::PBXVariantGroup }

if variant_group.nil?
  variant_group = project.new(Xcodeproj::Project::Object::PBXVariantGroup)
  variant_group.name = 'InfoPlist.strings'
  main_group << variant_group
  
  # Add to build phase
  resources_build_phase = target.resources_build_phase
  resources_build_phase.add_file_reference(variant_group)
end

# Add all language specific files to the variant group
languages = ['de', 'ja', 'en', 'es', 'it', 'ko', 'tr', 'pl', 'fr', 'nl', 'pt']
languages.each do |lang|
  file_path = "Garten_Simulation/#{lang}.lproj/InfoPlist.strings"
  if File.exist?(file_path)
    # Check if already in variant group
    unless variant_group.children.any? { |c| c.name == lang }
      file_ref = variant_group.new_reference(file_path)
      file_ref.name = lang
    end
  end
end

project.save
puts "Added InfoPlist.strings to Xcode project successfully."
