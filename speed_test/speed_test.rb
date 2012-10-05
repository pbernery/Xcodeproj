#!/usr/bin/env ruby
#
# Creates a project and add file and group references recursively
require 'rubygems'
require 'yaml'

require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))

$:.unshift((ROOT + 'ext').to_s)
$:.unshift((ROOT + 'lib').to_s)
require 'xcodeproj'

def create_references(contents, parent_group, build_phase)
  contents.each do |entry|
    if entry.is_a? Hash
      group = parent_group.groups.new(:name => entry.keys.first)
      create_references(entry.values.first, group, build_phase)
    else
      print "."
      file = parent_group.create_file(entry)
      file.source_tree = "<group>"
      build_phase.files << file
    end
  end
end

# Retrieve UUIDs of all files in `group` recursively.
def file_uuids_of_group(group)
  uuids = Array.new
  group.groups.each { |g| uuids.concat(file_uuids_of_group(g)) }
  group.files.each { |f| uuids << f.uuid }
  uuids
end

# Remove references of build files in `build_phase` that are in `group`.
def remove_build_file_references(group, build_phase)
  uuids = file_uuids_of_group(group)
  build_phase.build_files.each do |build_file|
    print "."
    build_file.destroy if uuids.include?(build_file.file.uuid)
  end
end

project = Xcodeproj::Project.new
phase = project.objects.add(Xcodeproj::Project::PBXResourcesBuildPhase)
resources_group = project.groups.new(:name => "Resources")
contents = YAML.load(File.read("sample_tree.yml"))

print "Creating references..."
create_start_time = Time.now
create_references(contents, resources_group, phase)
create_end_time = Time.now
puts ""
puts "Created references in #{create_end_time - create_start_time}s"

print "Removing references..."
destroy_start_time = Time.now
remove_build_file_references(resources_group, phase)
destroy_end_time = Time.now
puts ""
puts "Removed references in #{destroy_end_time - destroy_start_time}s"
