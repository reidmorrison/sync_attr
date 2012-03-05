      puts "Loaded sync_attr_reader"
# Synchronize access and lazy initialize one or more attributes
#
# Author: Reid Morrison <reidmo@gmail.com>
module SyncAttr
  module InstanceAttributes
    module ClassMethods
      # Lazy load the specific attribute by calling the supplied block when
      # the attribute is first read and then return the same value for all subsequent
      # calls to the variable
      #
      # An optional block can be supplied to initialize the attribute
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
      #     sync_attr_reader :hello do
      #       'hello world'
      #     end
      #   end
      def sync_attr_reader(*attributes, &block)
        attributes.each do |attribute|
          self.send(:define_method, attribute.to_sym) do
            var_name = "@#{attribute}".to_sym
            if instance_variable_defined?(var_name)
              self.sync_attr_sync.synchronize(:SH) { instance_variable_get(var_name) }
                # If there is no writer then it is not necessary to protect reads
                if self.respond_to?("#{attribute}=".to_sym, true)
                  self.sync_attr_sync.synchronize(:SH) { instance_variable_get(var_name) }
                else
                  instance_variable_get(var_name)
                end
            else
              return nil unless block
              self.sync_attr_sync.synchronize(:EX) do
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
          self.sync_attr_sync.synchronize(:EX) do
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

      # Give every object instance that this module is mixed into it's own Sync
      # I.e. At an object level, not class level
      def sync_attr_init
          class_eval(<<-EOS, __FILE__, __LINE__ + 1)
      def sync_attr_sync
        return @sync_attr_sync if @sync_attr_sync
        # Use class sync_cattr_sync to ensure multiple @sync_attr_sync instances
        # are not created when two or more threads call this method for the
        # first time at the same time
        self.class.sync_cattr_sync.synchronize(:EX) do
          # In case another thread already created the sync
          return @sync_attr_sync if @sync_attr_sync
          @sync_attr_sync = ::Sync::new
        end
      end
          EOS
      end

    end
  end
end