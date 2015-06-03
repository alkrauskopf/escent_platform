class Address < ActiveRecord::Base
  belongs_to :address_type
  belongs_to :organization
  belongs_to :user
  
  validates_presence_of :street1
  validates_presence_of :state, :if => :state_required?
  validates_presence_of :city
  validates_presence_of :postal_code 
  
  validates_format_of :postal_code, :with => /^[\w]+-{0,1}[\w]*$/, :message => 'not valid',
                      :allow_nil => false

  validates_format_of :street1, :with => /^[\w\s'-`]+$/, :message => 'not valid', :allow_nil => false
  
  validates_format_of :street2, :with => /^[\w\s'-`]*$/, :message => 'not valid', :allow_nil => false
  
  validates_format_of :city, :with => /^[\w\s'-`]+$/, :message => 'not valid', :allow_nil => false
  
  named_scope :physical, :conditions => {:address_type_id => AddressType.physical}
  
  def after_initialize
    if self.address_type.nil?
      self.address_type = AddressType.physical
    end
    self.country = "US" if self.country.nil?
  end
  
  STATES = [
    # Displayed         stored in DB
    [ "Alabama",        "AL" ],
    [ "Alaska",         "AK" ],
    [ "Arizona",        "AZ" ],
    [ "Arkansas",       "AR" ],
    [ "California",     "CA" ],

    [ "Colorado",       "CO" ],
    [ "Connecticut",    "CT" ],
    [ "Delaware",       "DE" ],
    [ "Dist Columbia",  "DC" ],
    [ "Florida",        "FL" ],
    [ "Georgia",        "GA" ],

    [ "Hawaii",         "HI" ],
    [ "Idaho",          "ID" ],
    [ "Illinois",       "IL" ],
    [ "Indiana",        "IN" ],
    [ "Iowa",           "IA" ],
    [ "Kansas",         "KS" ],

    [ "Kentucky",       "KY" ],
    [ "Louisiana",      "LA" ],
    [ "Maine",          "ME" ],
    [ "Maryland",       "MD" ],
    [ "Massachusetts",  "MA" ],
    [ "Michigan",       "MI" ],

    [ "Minnesota",      "MN" ],
    [ "Mississippi",    "MS" ],
    [ "Missouri",       "MO" ],
    [ "Montana",        "MT" ],
    [ "Nebraska",       "NE" ],
    [ "Nevada",         "NV" ],

    [ "New Hampshire",  "NH" ],
    [ "New Jersey",     "NJ" ],
    [ "New Mexico",     "NM" ],
    [ "New York",       "NY" ],
    [ "North Carolina", "NC" ],
    [ "North Dakota",   "ND" ],

    [ "Ohio",           "OH" ],
    [ "Oklahoma",       "OK" ],
    [ "Oregon",         "OR" ],
    [ "Pennsylvania",   "PA" ],
    [ "Rhode Island",   "RI" ],
    [ "South Carolina", "SC" ],

    [ "South Dakota",   "SD" ],
    [ "Tennessee",      "TN" ],
    [ "Texas",          "TX" ],
    [ "Utah",           "UT" ],
    [ "Vermont",        "VT" ],
    [ "Virginia",       "VA" ],

    [ "Washington",     "WA" ],
    [ "West Virginia",  "WV" ],
    [ "Wisconsin",      "WI" ],
    [ "Wyoming",        "WY" ]
  ]    
  
  protected
  def state_required?
    self.country == "US"      
  end
end
