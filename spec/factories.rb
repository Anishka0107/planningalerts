Factory.define :authority do |a|
  a.full_name "Acme Local Planning Authority"
  a.short_name {|b| b.full_name}
end

Factory.define :application do |a|
  a.association :authority
  a.council_reference "001"
  a.date_scraped {|b| 10.minutes.ago}
end

Factory.define :comment do |c|
  c.email "matthew@openaustralia.org"
  c.name "Matthew Landauer"
  c.text "a comment"
  c.address "12 Foo Street"
  c.association :application
end