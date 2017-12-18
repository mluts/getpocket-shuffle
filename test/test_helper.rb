# frozen_string_literal: true

require 'bundler/setup'
require 'minitest/autorun'
require 'webmock/minitest'

$LOAD_PATH << File.expand_path('../lib', __dir__)
$LOAD_PATH << File.expand_path('..', __dir__)

require 'app'
require 'getpocket'
