# frozen_string_literal: true

require 'active_model'
require 'zeitwerk'

require_relative 'active_call/version'

loader = Zeitwerk::Loader.for_gem
loader.setup

module ActiveCall
  class Error < StandardError; end
end
