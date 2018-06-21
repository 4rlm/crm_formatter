# frozen_string_literal: false

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'crm_formatter'
# require 'rubygems'
# require 'activesupport'
# require "active_support/all"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec
task :test => :spec

task :console do
  require 'irb'
  require 'irb/completion'
  require 'crm_formatter' # You know what to do.
  require "active_support/all"
  ARGV.clear
  binding.pry

  CrmFormatter.run_wrap
  IRB.start
end












# gem install activesupport -v 5.0.0
# gem install activesupport


##################################################################
####### !ORIGINAL! SAVE #######
# Perfect!
# 1. 'cd-crm' ||crm_formatter/lib
# 2. Load runner at bottom before start.
# 3. Allows for Active Record & Binding.pry.
# task :console do
#   require 'irb'
#   require 'irb/completion'
#   require 'crm_formatter' # You know what to do.
#   ARGV.clear
#   CrmFormatter.run
#   IRB.start
# end
#############################
  # alias xx='exit exit'
  # alias ss='rake console'
  # alias cd-crm="cd ~/Desktop/gemdev/crm_formatter"
  # alias cd-gem.app="cd ~/Desktop/gemdev/gem_tester"
  # alias cd-lib="cd ~/Desktop/gemdev/crm_formatter/lib"
#############################
