class Player
  def initialize()
  	@prior_health = 20
  	@health = 20
  end
  
  def play_turn(warrior)
    if warrior.respond_to?(:health)
      @health = warrior.health
    else
      @health = 20
    end
    if warrior.respond_to?(:feel)
      @empty = warrior.feel.empty?
      @captive = warrior.feel.captive?
      @enemy_archer = warrior.feel.to_s == 'Archer'
      @wall = warrior.feel.wall?
    else
      @empty = true
	  @captive = false
	  @wall = false
	  @enemy_archer = false
    end
    if warrior.respond_to?(:look)
      @first_thing = warrior.look.find {|space| !space.empty? }
      @shootable = false
      if @first_thing != nil && @first_thing.to_s != 'wall'
        @shootable = !@first_thing.captive?
      end
    end
    @can_pivot = warrior.respond_to?(:pivot)
    act(warrior)
    @prior_health = @health
  end
  
  def act(warrior)
    if @health < @prior_health && @empty && @first_thing != nil && @first_thing.to_s != 'Archer'
      warrior.pivot!
      return
    end
    
    if @shootable
      warrior.shoot!
      return
    end
    
  	if @empty && @health < 20 && @prior_health <= @health
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
