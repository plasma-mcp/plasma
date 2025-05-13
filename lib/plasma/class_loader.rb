# frozen_string_literal: true

module Plasma
  # Handles class loading and path resolution for PLASMA classes
  class ClassLoader
    class << self
      def find_loader(module_name, class_name)
        Zeitwerk::Registry.loaders.find do |l|
          inceptions = l.instance_variable_get(:@inceptions)
          next unless inceptions

          map = inceptions.instance_variable_get(:@map)
          next unless map

          map[module_name]&.key?(class_name)
        end
      end

      def get_path_from_loader(loader, module_name, class_name)
        inceptions = loader.instance_variable_get(:@inceptions)
        return nil unless inceptions

        map = inceptions.instance_variable_get(:@map)
        return nil unless map

        map.dig(module_name, class_name)
      end
    end
  end
end
