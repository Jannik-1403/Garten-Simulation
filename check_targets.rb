require 'xcodeproj'
project = Xcodeproj::Project.open('Garten_Simulation.xcodeproj')

['Garten_Simulation', 'GartenWidgetExtension'].each do |target_name|
  target = project.targets.find { |t| t.name == target_name }
  if target
    puts "Files in #{target_name}:"
    target.source_build_phase.files.each do |f|
      path = f.file_ref&.path || f.file_ref&.name
      puts "  #{path}" if path && path.downcase.include?('activity')
    end
  end
end
