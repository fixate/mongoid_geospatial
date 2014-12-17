module Mongoid
  module Geospatial
    class GeometryField < Array

      def bounding_box
        max_x, min_x = -Float::MAX, Float::MAX
        max_y, min_y = -Float::MAX, Float::MAX
        each do |point|
          max_y = point[1] if point[1] > max_y
          min_y = point[1] if point[1] < min_y
          max_x = point[0] if point[0] > max_x
          min_x = point[0] if point[0] < min_x
        end
        [[min_x, min_y], [max_x, max_y]]
      end
      alias_method :bbox, :bounding_box

      def center_point
        min, max = *bbox
        [(min[0] + max[0]) / 2.0, (min[1] + max[1]) / 2.0]
      end
      alias_method :center, :center_point

      def radius(r = 1)
        [center, r]
      end

      def radius_sphere(r = 1, unit = :km)
        radius r.to_f / Mongoid::Geospatial.earth_radius[unit]
      end

      def mongodb_geotype
        self.class.name.split('::').last
      end

      alias_method :to_coordinates, :to_a

      def mongoize
        {
          'type' => mongodb_geotype,
          'coordinates' => to_coordinates
        }
      end

      class << self

        # Database -> Object
        def demongoize(o)
          case o
          when GeometryField then o
          when Array then new(o)
          when Hash
            if o.has_key?('coordinates')
              new(o['coordinates'])
            else
              field_error!
            end
          else
            field_error!
          end
        end

        # Object -> Database
        def mongoize(o)
          self.demongoize(o).mongoize
        end

        private

        def field_error!
          raise ArgumentError, <<-MSG.strip
            Geometry field should be an array or hash in the following form:
            e.g. {"type": "Polygon", "coordinates": [[[1,2], ....]]}
          MSG
        end
      end
    end
  end
end
