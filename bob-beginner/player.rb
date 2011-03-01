class Player
  def play_turn(warrior)
    @prior_health ||= warrior.health
    @full_health ||= warrior.health
    @warrior = warrior
    @mood ||= :having_a_fit
    
    hurt = (warrior.health < @prior_health)
    
    if (@mood == :charging)
      # close eyes, keep charging
    else
      if (hurt)
        if (@was_empty)
          @mood = :charging
        else
          @mood = :baiting
        end
      elsif (!warrior.feel.empty?)
        @mood = :baiting
      else
        @mood = :exploring
      end
    end
    
    case @mood
    when :exploring
      explore!
    when :charging
      charge!
    when :baiting
      bait!
    else
      raise "Bob collapses to the ground, foaming and twitching."
    end
    
    @prior_health = warrior.health
    @was_empty = warrior.feel.empty?
  end
  
  def a_bit_sick?
    (@warrior.health < @full_health)
  end
  
  def charge!
    @warrior.feel.empty? ? @warrior.walk! : @warrior.attack!
  end
  
  def explore!
    a_bit_sick? ? @warrior.rest! : @warrior.walk!
  end
  
  def bait!
    if (a_bit_sick?)
      @warrior.walk!(:backward)
    else
      @warrior.attack!
    end
  end
end
