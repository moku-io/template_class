module TemplateClass
  module Template
    extend ActiveSupport::Concern

    included do
      next unless is_a? Class

      mattr_reader :cache,
                   default: Hash.new { |h, k|
                     h[k] = Class.new
                   },
                   instance_accessor: false

      singleton_class.delegate :[], :[]=, to: :cache
    end

    class CacheClassConstructor
      attr_reader :key
      attr_reader :owner

      delegate_missing_to :owner

      def initialize key, owner
        @key = key
        @owner = owner
      end

      def new base_class=::Object, &block
        klass = Class.new base_class
        owner[key] = klass

        outer_self = self

        klass.define_singleton_method :to_s do
          if respond_to?(:anonymous?) ? anonymous? : name.nil?
            "#{outer_self.owner}<#{outer_self.key}>"
          else
            super()
          end
        end

        klass.singleton_class.alias_method :inspect, :to_s

        klass.class_exec(&block)
        klass
      end
    end

    class CacheModuleConstructor
      attr_reader :key
      attr_reader :owner

      delegate_missing_to :owner

      def initialize key, owner
        @key = key
        @owner = owner
      end

      def new &block
        mod = Module.new
        owner[key] = mod

        outer_self = self

        mod.define_singleton_method :to_s do
          "#{outer_self.owner}<#{outer_self.key}>"
        end

        mod.singleton_class.alias_method :inspect, :to_s

        mod.module_exec(&block)
        mod
      end
    end

    private_constant :CacheClassConstructor, :CacheModuleConstructor

    class_methods do
      def resolve_template_specialization &block
        cache.default_proc = proc do |h, k|
          class_constructor = CacheClassConstructor.new k, self
          module_constructor = CacheModuleConstructor.new k, self
          result = block.call k, class_constructor, module_constructor

          h[k] = result unless h.key? k

          result
        end
      end
    end
  end
end
