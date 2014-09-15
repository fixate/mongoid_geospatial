module Mongoid
  module Geospatial
    class Polygon < GeometryField
      def to_coordinates
        [to_a]
      end
    end
  end
end
