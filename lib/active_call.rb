# frozen_string_literal: true

require 'active_model'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/active_call/error.rb")
loader.collapse("#{__dir__}/active_call/concerns")
loader.setup

require_relative 'active_call/error'
require_relative 'active_call/version'

module ActiveCall; end
