def select_date(date, options = {})
  raise ArgumentError, 'from is a required option' if options[:from].blank?
  field = options[:from].to_s
  select date.year.to_s,               from: "#{field}_1i"
  select Date::MONTHNAMES[date.month], from: "#{field}_2i"
  select date.day.to_s,                from: "#{field}_3i"
end

def reset_indexes
  Location.import force: true, refresh: true
  Procedure.indexable.import force: true, refresh: true
  Hospital.import force: true, refresh: true
end

def create_locations_ancestry(region, country, city)
  region = create :location, name: region
  country = create :location, name: country, parent: region
  city = create :location, name: city, parent: country
  [region, country, city]
end
