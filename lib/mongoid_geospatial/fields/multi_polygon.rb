module Mongoid
  module Geospatial
    class MultiPolygon < GeometryField
      def to_coordinates
        [to_a.map(&:to_a)]
      end
    end
  end
end
