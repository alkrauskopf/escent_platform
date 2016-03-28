class EltCycleElement < ActiveRecord::Base

  belongs_to :elt_cycle
  belongs_to :elt_element

  def self.for_element(element)
    where('elt_element_id = ?', element.id)
  end

  def self.for_cycle(cycle)
    where('elt_cycle_id = ?', cycle.id)
  end
end
