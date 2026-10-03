require 'xcodeproj'
project = Xcodeproj::Project.open("Garten_Simulation.xcodeproj")
target = project.targets.find { |t| t.name == 'Garten_Simulation' }
group = project.main_group.find_subpath(File.join("Garten_Simulation", "Views", "CleaningHabit"), true)

# check if file already exists in group
unless group.files.any? { |f| f.path == "CleaningTaskRowView.swift" }
  file = group.new_file("CleaningTaskRowView.swift")
  target.add_file_references([file])
end

unless group.files.any? { |f| f.path == "CleaningTaskEditorSheet.swift" }
  file2 = group.new_file("CleaningTaskEditorSheet.swift")
  target.add_file_references([file2])
end

project.save
puts "Files added to xcodeproj"
