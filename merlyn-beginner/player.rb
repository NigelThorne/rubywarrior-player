class Player
  def initialize()
  	@prior_health = 20
  end
  
  def play_turn(warrior)
    @health = warrior.health
    @health_decreased = @health < @prior_health
    @empty = warrior.feel.empty?
    @captive = warrior.feel.captive?

    @first_thing = warrior.look.find {|space| !space.empty? }
    @shootable = false
    if @first_thing != nil && @first_thing.to_s != 'wall'
      @shootable = !@first_thing.captive?
    end
    if @first_thing != nil
      @first_thing = @first_thing.to_s
    end

    act(warrior)
    @prior_health = @health
  end
  
  def act(warrior)
    if @health_decreased && @first_thing != 'Archer'
      warrior.pivot!
      return
    end
    
    if @shootable && @first_thing != 'Archer'
      warrior.shoot!
      return
    end
    
  	if @captive
  	  warrior.rescue!
  	  return
  	end
    
    if @empty
      warrior.walk!
      return
	end
	
	if @first_thing == 'wall'
	  warrior.pivot!
	  return
	end
	
    warrior.attack!
  end
end
