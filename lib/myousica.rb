module Myousica
  TONES = %w[ C C# D D# E F F# G G# A A# B ]
  
  def self.key(tone)
    TONES.index(tone.to_s.upcase)
  end
end
