module AllInEventFinder
  def in_event(event)
    find :all, :conditions => ["event_id = ?", event]
  end
end

module DateFinder
  def recent(options = {})
    options = {:period => 30.days}.merge(options)
    cutoff_date = Time.now - options[:period]
    find :all, :conditions => ["updated_at > ? OR created_at > ?", cutoff_date, cutoff_date]
  end
end


module FormFinder
  def of_form(form, options = {})
    form = form.to_sym
    form_id = form.is_numeric? ? form : AttributeMapping::forms[form][:id]
    if AttributeMapping::forms[form][:administrator_based]
      conditions = ["administrator_id = ? AND form_id = ?", options[:administrator], form_id]
    else
      conditions = ["form_id = ?", form_id]
    end
    find :all, :conditions => conditions, :order => "position"
  end
end

module TierFinder
  def in_tier(tier, qty=nil)
    if qty.nil?
      find :all, :conditions => ["tier_id = ?", tier]
    else
      find :all, :conditions => ["quantity_break <= ? AND tier_id = ?", qty, tier]
    end
  end
end