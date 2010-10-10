module ValidatesTimeliness
  module Extensions
    module FormtasticExtension
      extend ActiveSupport::Concern

      # Intercepts Formtastic's  date and time helpers. which work a little
      # different than the regular Rails ones. Instead of calling the 
      # datetime_selector helper, Formtastic brings its own super helper:
      # date_or_datetime_input, which needs to be intercepted. Furthermore
      # Formtastic doesn't use the value method.

      included do
        alias_method_chain :date_or_datetime_input, :timeliness
      end

      module InstanceMethods

        TimelinessDateTime = Struct.new(:year, :month, :day, :hour, :min, :sec)

        def date_or_datetime_input_with_timeliness(method, options)
          prms = {:selected => collect_multiple_param(method)}.merge!(options) #explicitly defined option trumps
          date_or_datetime_input_without_timeliness(method, prms)
        end

        def collect_multiple_param(method_name)
          object_name = @object.class.to_s.downcase
          pairs = @template.params[object_name].nil? ? [] : @template.params[object_name].select {|k,v| k =~ /^#{method_name}\(/ }
          return nil if pairs.empty?

          values = [nil] * 6
          pairs.map do |(param, value)|
            position = param.scan(/\(([0-9]*).*\)/).first.first
            values[position.to_i-1] = value.to_i
          end

          TimelinessDateTime.new(*values)
        end


      end

    end
  end
end
