class Player
  def initialize()
  	@prior_health = 20
  end
  
  def play_turn(warrior)
    @health = warrior.health
    @health_decreased = @health < @prior_health
	
	@ahead = warrior.look.find {|space| !space.empty? }
	@ahead = [] if @ahead == nil
	
	@behind = warrior.look(:backward).find {|space| !space.empty? }
	@behind = [] if @behind == nil
	
    act(warrior)

    @prior_health = @health
  end
  
  def act(warrior)
	if @behind.to_s == 'Archer'
	  warrior.shoot!(:backward)
	  return
	end
    
    if @ahead.to_s != 'Archer' && @behind.to_s == 'Captive'
      warrior.pivot!
      return
    end
    
  	if !@ahead.empty? && @ahead.enemy? && (@ahead.to_s != 'Sludge' || @health < 10)
	  warrior.shoot!
	  return
	end
	
	if warrior.feel.captive?
  	  warrior.rescue!
  	  return
  	end
    
    if warrior.feel.empty?
      warrior.walk!
      return
	end
	
	if warrior.feel.wall?
	  warrior.pivot!
	  return
	end
	
    warrior.attack!
  end
end
