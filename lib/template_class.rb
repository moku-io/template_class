# frozen_string_literal: true

require_relative 'template_class/version'

module TemplateClass
  class Error < StandardError; end
end

require_relative 'template_class/template'
