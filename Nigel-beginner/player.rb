
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
    @facing ||= :forward
    @max_health ||= 20
    @last_health ||= @max_health
    @you_have_been_hurt_since_last_turn = health < @last_health
    forward = feel(:forward)
    @you_are_next_to_something = !forward.empty?
    @you_are_next_to_a_captive = @you_are_next_to_something && forward.captive?
  end
  
  def health
    @warrior.respond_to?(:health) ? @warrior.health : 20
  end
  
  def feel(direction)
    @warrior.respond_to?(:feel) ? @warrior.feel(direction) : []
  end

  def update_stats
    @last_health = health
@you_were_next_something_last_turn = @you_are_next_to_something 
  end
  
  def make_a_new_plan
    return AttackArcher.new if(being_shot?) 
    return AttackSludge.new if(being_hit? || about_to_be_hit?)
    return AttackWizard.new unless(direction_of_wizard.nil?)
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
    found_enemy?(:forward)
  end
    
  def healed?
    health == @max_health
  end
  
  def is_near_death?
    health <= @max_health/2
  end
  
  def found_enemy?(direction)
    (!feel(direction).empty? && 
    !found_captive?(direction) && 
    !found_wall?(direction))
  end
  
  def found_captive?(direction)
    !feel(direction).empty? && 
    feel(direction).respond_to?(:"captive?") &&
    feel(direction).captive?    
  end
  
  def found_wall?(direction)
    !feel(direction).empty? && 
    feel(direction).respond_to?(:"wall?") &&
    feel(direction).wall?    
  end
  
  def direction_of_wizard()
    [:forward, :backward, :right, :left].find{|direction| can_see_wizard?(direction)}
  end
  
  # true if location contains enemy and all previous locations were empty
  def can_see_wizard?(direction)
    return false unless @warrior.respond_to?(:look)
    look(direction).each{|location|
      return true if contains_enemy?(location)
      return false unless location.empty?      
      }
    return false    
  end
  
  
  def contains_enemy?(location)
    !location.nil? && !location.empty? && !location.captive? && !location.wall?
  end

  def method_missing(sym, *args, &block)
    @warrior.send(sym, *args, &block)
  end
end

class AttackWizard
  def perform(warrior)
    direction = warrior.direction_of_wizard
    return true if(direction.nil?)

    warrior.shoot!(direction) 
    return false
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
    return true if warrior.found_enemy?(:forward) or warrior.direction_of_wizard != nil
    if(warrior.found_captive?(:forward))
      warrior.rescue!
    elsif(warrior.found_wall?(:forward))      
      warrior.pivot!(:backward)      
    else
      warrior.walk!
    end
    false
  end
end
