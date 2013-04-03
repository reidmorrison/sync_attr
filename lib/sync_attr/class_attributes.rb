# Synchronize access and lazy initialize one or more variables in a class
#
# Author: Reid Morrison <reidmo@gmail.com>
module SyncAttr
  module ClassAttributes
    module ClassMethods
      # Lazy load the specific class attribute by calling the supplied block when
      # the attribute is first read and then return the same value for all subsequent
      # calls to the class variable
      #
      # An optional block can be supplied to initialize the synchronized class attribute
      # when first read. Acts as a thread safe lazy initializer. The block will only
      # be called once even if several threads call the reader at the same time
      #
      # Example:
      #   class MyClass
      #     include SyncAttr
      #
      #     # Generates a reader for the class attribute 'hello'
      #     # and Lazy initializes the value to 'hello world' only on the first
      #     # call to the reader
      #     sync_cattr_reader :hello do
      #       'hello world'
      #     end
      #   end
      def sync_cattr_reader(*attributes, &block)
        attributes.each do |attribute|
          metaclass.instance_eval do
            define_method(attribute.to_sym) do
              var_name = "@@#{attribute}".to_sym
              if class_variable_defined?(var_name)
                # If there is no writer then it is not necessary to protect reads
                if self.respond_to?("#{attribute}=".to_sym, true)
                  sync_cattr_sync.synchronize(:SH) { class_variable_get(var_name) }
                else
                  class_variable_get(var_name)
                end
              else
                return nil unless block
                sync_cattr_sync.synchronize(:EX) do
                  # Now that we have exclusive access make sure that another thread has
                  # not just initialized this attribute
                  if class_variable_defined?(var_name)
                    class_variable_get(var_name)
                  else
                    class_variable_set(var_name, class_eval(&block))
                  end
                end
              end
            end
          end
        end
      end

      # Generates a writer to set a synchronized attribute
      # Supply a Proc ensure an attribute is not being updated by another thread:
      #   MyClass.count = Proc.new {|count| (count||0) + 1}
      def sync_cattr_writer(*attributes)
        attributes.each do |attribute|
          class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        def self.#{attribute}=(value)
          sync_cattr_sync.synchronize(:EX) do
            if value.is_a?(Proc)
              current_value = @@#{attribute} if defined?(@@#{attribute})
              @@#{attribute} = value.call(current_value)
            else
              @@#{attribute} = value
            end
          end
        end
          EOS
        end
      end

      # Generate a class reader and writer for the attribute
      def sync_cattr_accessor(*attributes, &block)
        sync_cattr_writer(*attributes)
        sync_cattr_reader(*attributes, &block)
      end

      # Returns the metaclass or eigenclass so that we
      # can dynamically generate class methods
      # With thanks, see: https://gist.github.com/1199817
      def metaclass
        class << self;
          self
        end
      end

      # Returns the sync used by the included class to synchronize access to the
      # class attributes
      def sync_cattr_sync
        @sync_cattr_sync ||= ::Sync.new
      end

      protected

      # Give each class that this module is mixed into it's own Sync
      def sync_cattr_init
        @sync_cattr_sync = ::Sync.new
      end

    end
  end
end
