
class Player
  def play_turn(warrior)
    @warrior = warrior
    calc_stats
    
    if(@plan.nil? || @plan.perform(self))
      @plan = make_a_new_plan
      @plan.perform(self)
    end
        
    update_stats
  end
  
  def calc_stats
    @max_health ||= health
    @last_health ||= health
    @you_have_been_hurt_since_last_turn = health < @last_health
    @you_are_next_to_something = !feel(:forward).empty?
    @you_are_next_to_a_captive = feel(:forward).captive?
  end

  def update_stats
    @last_health = health
@you_were_next_something_last_turn = @you_are_next_to_something 
  end
  
  def make_a_new_plan
    return AttackArcher.new if(being_shot?) 
    return AttackSludge.new if(being_hit? || about_to_be_hit?)
    return Explore.new
  end
  
  def being_shot?
    !@you_were_next_something_last_turn && 
    @you_have_been_hurt_since_last_turn
  end
  
  def being_hit?
    @you_were_next_something_last_turn && 
    @you_have_been_hurt_since_last_turn
  end
  
  def about_to_be_hit?
    @you_are_next_to_something_evil
  end
    
  def healed?
    health == @max_health
  end
  
  def is_near_death?
    health <= @max_health/3
  end
  
  def found_enemy?(direction)
    !feel(direction).empty? && !feel(:forward).captive?
  end

  def method_missing(sym, *args, &block)
    @warrior.send(sym, *args, &block)
  end
end

class AttackArcher
  def initialize()
    @found_archer = false
    @killed_archer = false
  end

  def perform(warrior)
    if(@found_archer)
      @killed_archer = warrior.feel(:forward).empty?
    else
      @found_archer = warrior.found_enemy?(:forward)
    end

    return true if(@killed_archer)
    
    if(@found_archer)
      warrior.attack!(:forward)
    else
      warrior.walk!(:forward)
    end
    
    false
  end
end

class AttackSludge
  def initialize()
    @resting = false
  end
  
  def perform(warrior)    
    @resting = false if(warrior.healed?)

    if(@resting)
      if warrior.feel(:forward).empty?
        warrior.rest!
      else
        warrior.walk!(:backward)        
      end
      return false
    end
    
    return true if warrior.feel(:forward).empty?
    if(!warrior.is_near_death?)
      warrior.attack!
    else
      @resting = true
      warrior.walk!(:backward)
    end
    false
  end
end

class Explore
  def perform(warrior)
    return true if warrior.found_enemy?(:forward)
    if(warrior.feel(:forward).captive?)
      warrior.rescue!
    else
      warrior.walk!
    end
    false
  end
end
