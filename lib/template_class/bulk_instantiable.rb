module TemplateClass
  module BulkInstantiable
    extend ActiveSupport::Concern

    class_methods do
      def bulk_instantiate(*args, into:, with_overrides: defined?(Zeitwerk))
        constants(false)
          .map { |constant_name| const_get(constant_name) }
          .map do |constant|
            into.const_set constant.name.demodulize.to_sym, constant[*args]
          end
          .tap { return unless with_overrides } # rubocop:disable Lint/NonLocalExitFromIterator
          .map do |instance|
            Object
              .const_source_location(instance.module_parent_name)
              .first
              .delete_suffix('.rb')
              .then { "#{_1}/#{instance.name.demodulize.underscore}" }
          end
          .each do |path|
            require path
          rescue LoadError
            nil
          end
      end
    end
  end
end
