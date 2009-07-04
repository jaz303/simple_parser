require 'simple_parser'

class Calculator < SimpleParser::Parser
  
  TOKENS = [
    [ /\s+/ ],
    [ '(', :lparen ],
    [ ')', :rparen ],
    [ /-?\d+(\.\d+)?/, :number, :to_f ],
    [ '+', :+ ],
    [ '-', :- ],
    [ '*', :* ],
    [ '/', :/ ]
  ]
  
  def initialize
    super(TOKENS)
  end
  
private

  def parse_program
    parse_expression
  end
  
  def parse_expression
    parse_plus_minus
  end
  
  def parse_plus_minus
    value = parse_times_divide
    while [:+, :-].include?(token_name)
      op = token_name
      accept
      value = value.send(op, parse_times_divide)
    end
    value
  end
  
  def parse_times_divide
    value = parse_primary
    while [:*, :/].include?(token_name)
      op = token_name
      accept
      value = value.send(op, parse_primary)
    end
    value
  end
  
  def parse_primary
    if token_name == :number
      value = token_value
      accept
    elsif token_name == :lparen
      accept
      value = parse_expression
      accept :rparen
    end
    value
  end
  
end

c = Calculator.new
puts c.eval("5 + (10 * (5 + 6)) / (2 + 2)")