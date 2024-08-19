module TemplateClass
  module BulkInstantiable
    extend ActiveSupport::Concern

    class_methods do
      def bulk_instance(*args, into:, with_overrides: defined?(Zeitwerk))
        constants(false)
          .map { |constant_name| const_get(constant_name) }
          .map do |constant|
            into.const_set constant.name.demodulize.to_sym, constant[*args]
          end
          .tap { return unless with_overrides } # rubocop:disable Lint/NonLocalExitFromIterator
          .each do |instance|
            require instance.name.underscore
          rescue LoadError
            nil
          end
      end
    end
  end
end
