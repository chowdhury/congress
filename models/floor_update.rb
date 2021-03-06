class FloorUpdate
  include Api::Model
  publicly :queryable

  basic_fields :chamber, :legislative_day, :timestamp, 
    :update, :roll_ids, :bill_ids, :legislator_ids, :congress
  
  search_fields :update
  
  
  
  include Mongoid::Document
  
  index chamber: 1
  index legislative_day: 1
  index roll_ids: 1
  index bill_ids: 1
  index legislator_ids: 1
  index timestamp: 1
  index congress: 1
end