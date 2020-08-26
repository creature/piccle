require 'sequel'

# Represents a location in the system - either just a lat/long point (to be geocoded later) or a lat/long named
# with "city", "state", "country". Countries are normally countries, but overall it's more like "small area", "wider
# geographic area", "big geographic area".
class Piccle::Location < Sequel::Model
  def before_create
    self.created_at ||= Time.now
    super
  end
end
