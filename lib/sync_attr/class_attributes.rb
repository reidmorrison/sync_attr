class Module
  # Lazy load the specific class attribute by calling the supplied block when
  # the attribute is first read and then return the same value for all subsequent
  # calls to the class variable
  #
  # An optional block can be supplied to initialize the synchronized class attribute
  # when first read. Acts as a thread safe lazy initializer. The block will only
  # be called once even if several threads call the reader at the same time
  #
  # Example:
  #   require 'sync_attr'
  #   class MyClass
  #     # Generates a reader for the class attribute 'hello'
  #     # and Lazy initializes the value to 'hello world' only on the first
  #     # call to the reader
  #     sync_cattr_reader :hello do
  #       'hello world'
  #     end
  #   end
  def sync_mattr_reader(*attributes, &block)
    attributes.each do |attribute|
      raise NameError.new("invalid attribute name: #{attribute}") unless attribute =~ /^[_A-Za-z]\w*$/
      mutex_var_name = "@@sync_attr_#{attribute}".to_sym
      class_variable_set(mutex_var_name, Mutex.new) unless class_variable_defined?(mutex_var_name)
      # Class reader with lazy initialization for the first thread that calls this method
      # Use metaclass/eigenclass to dynamically generate class methods
      (class << self; self; end).instance_eval do
        define_method(attribute.to_sym) do
          var_name = "@@#{attribute}".to_sym
          if class_variable_defined?(var_name)
            # If there is no writer then it is not necessary to protect reads
            if self.respond_to?("#{attribute}=".to_sym, true)
              class_variable_get(mutex_var_name).synchronize { class_variable_get(var_name) }
            else
              class_variable_get(var_name)
            end
          else
            return nil unless block
            class_variable_get(mutex_var_name).synchronize do
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
  alias :sync_cattr_reader :sync_mattr_reader

  # Generates a writer to set a synchronized attribute
  # Supply a Proc ensure an attribute is not being updated by another thread:
  #   MyClass.count = Proc.new {|count| (count||0) + 1}
  def sync_mattr_writer(*attributes)
    attributes.each do |attribute|
      mutex_var_name = "@@sync_attr_#{attribute}".to_sym
      class_variable_set(mutex_var_name, Mutex.new) unless class_variable_defined?(mutex_var_name)
      class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        def self.#{attribute}=(value)
          #{mutex_var_name}.synchronize do
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
  alias :sync_cattr_writer :sync_mattr_writer

  # Generate a class reader and writer for the attribute
  def sync_mattr_accessor(*attributes, &block)
    sync_cattr_writer(*attributes)
    sync_cattr_reader(*attributes, &block)
  end
  alias :sync_cattr_accessor :sync_mattr_accessor
end
