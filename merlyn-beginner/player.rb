class Player
  def initialize()
  	@prior_health = 20
  end
  
  def play_turn(warrior)
    @health = warrior.health
    @health_decreased = @health < @prior_health
    @empty = warrior.feel.empty?
    @captive = warrior.feel.captive?
    @enemy_archer = warrior.feel.to_s == 'Archer'
    @wall = warrior.feel.wall?
    @first_thing = warrior.look.find {|space| !space.empty? }
    @shootable = false
    if @first_thing != nil && @first_thing.to_s != 'wall'
      @shootable = !@first_thing.captive?
    end
    @can_pivot = true
    act(warrior)
    @prior_health = @health
  end
  
  def act(warrior)
    if @health_decreased && @empty && @first_thing != nil && @first_thing.to_s != 'Archer'
      warrior.pivot!
      return
    end
    
    if @shootable
      warrior.shoot!
      return
    end
    
  	if @empty && @health < 20 && !@health_decreased
  	  warrior.rest!
  	  return
  	end
  	
  	if @health < 20 && !@empty && !@enemy_archer
  	  warrior.walk!(:backward)
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
	
	if @wall
	  warrior.pivot!
	  return
	end
	
    warrior.attack!
  end
end
