module PublicPersona
  BLOWFISH = Crypt::Blowfish.new(PUBLIC_ID_SECRET)
  
  def self.append_features(klass)
    def klass.id_from_public_id(public_id)
      BLOWFISH.decrypt_block(public_id.split(//).in_groups_of(2).collect{|g| g.join.hex.chr}.join).to_i(32)
    end
    
    def klass.find_by_public_id(public_id)
      self.find id_from_public_id(public_id)
    end
    
    super
  end
  
  # blowfish takes a 8 byte block
  def public_id
    self.id ? PublicPersona::BLOWFISH.encrypt_block("%8s" % self.id.to_s(32)).unpack("C*").collect{|x| x.to_s(16).rjust(2, '0')}.join : nil
  end
  
  def to_param
    self.public_id
  end
end