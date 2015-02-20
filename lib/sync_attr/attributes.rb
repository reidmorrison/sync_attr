module SyncAttr
  module Attributes
    module ClassMethods
      # Thread-safe access to attributes in an object.
      #
      # Attributes protected with `sync_attr_reader`, `sync_attr_writer`, and/or
      # `sync_attr_accessor` can be safely read and written across many threads.
      #
      # Additionally `sync_attr_reader` supports lazy loading the corresponding
      # attribute in a thread-safe way. While the value is being calculated / loaded
      # all other threads calling that attribute will block until the value is available
      #
      # An optional block can be supplied to initialize the attribute
      # when first read. Acts as a thread safe lazy initializer. The block will only
      # be called once even if several threads call the reader at the same time
      #
      # Example:
      #   class MyClass
      #     include SyncAttr::Attributes
      #
      #     # Generates a reader for the attribute 'hello'
      #     # and Lazy initializes the value to 'hello world' only on the first
      #     # call to the reader
      #     sync_attr_reader :hello do
      #       'hello world'
      #     end
      #   end
      def sync_attr_reader(*attributes, &block)
        attributes.each do |attribute|
          self.send(:define_method, attribute.to_sym) do
            var_name = "@#{attribute}".to_sym
            if instance_variable_defined?(var_name)
              # If there is no writer then it is not necessary to protect reads
              if respond_to?("#{attribute}=".to_sym, true)
                @sync_attr_sync.synchronize(:SH) { instance_variable_get(var_name) }
              else
                instance_variable_get(var_name)
              end
            else
              return nil unless block
              @sync_attr_sync.synchronize(:EX) do
                # Now that we have exclusive access make sure that another thread has
                # not just initialized this attribute
                if instance_variable_defined?(var_name)
                  instance_variable_get(var_name)
                else
                  instance_variable_set(var_name, instance_eval(&block))
                end
              end
            end
          end
        end
      end

      # Generates a writer to set a synchronized attribute
      # Supply a Proc ensure an attribute is not being updated by another thread:
      #   my_object.count = Proc.new {|count| (count||0) + 1}
      def sync_attr_writer(*attributes)
        attributes.each do |attribute|
          class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        def #{attribute}=(value)
          @sync_attr_sync.synchronize(:EX) do
            if value.is_a?(Proc)
              current_value = @#{attribute} if defined?(@#{attribute})
              @#{attribute} = value.call(current_value)
            else
              @#{attribute} = value
            end
          end
        end
          EOS
        end
      end

      # Generate a reader and writer for the attribute
      def sync_attr_accessor(*attributes, &block)
        sync_attr_reader(*attributes, &block)
        sync_attr_writer(*attributes)
      end
    end

    def self.extend_object(obj)
      super(obj)
      obj.__send__(:init_sync_attr)
    end

    def self.included(base)
      base.extend(SyncAttr::Attributes::ClassMethods)
    end

    private

    # Use <tt>include SyncAttr::InstanceAttributes</tt> instead of this constructor
    def initialize(*args)
      super
      init_sync_attr
    end

    def init_sync_attr
      @sync_attr_sync = ::Sync.new
    end

  end
end