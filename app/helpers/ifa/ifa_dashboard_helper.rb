module Ifa::IfaDashboardHelper

  def hash_key(level, strand)
    if !level.nil? && !strand.nil?
      hash_key = level.id.to_s + strand.id.to_s
    else
      hash_key = ''
    end
    hash_key
  end

end
