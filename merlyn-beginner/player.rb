class Player
  def play_turn(warrior)
    if warrior.respond_to?(:health)
      @health = warrior.health
    else
      @health = 20
    end
    if warrior.respond_to?(:feel)
      @empty = warrior.feel.empty?
      @captive = warrior.feel.captive?
      puts warrior.feel.to_s
      @enemy_archer = warrior.feel.to_s == 'Archer'
    else
      @empty = true
	  @captive = false
    end
    act(warrior)
    @prior_health = @health
  end
  
  def act(warrior)
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
	
    warrior.attack!
  end
end
