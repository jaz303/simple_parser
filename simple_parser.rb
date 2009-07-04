require 'strscan'

module SimpleParser
  class Tokenizer
    include Enumerable
    
    def initialize(rules)
      @rules = rules.map { |r|
        r = r.dup
        pattern = r.shift
        pattern = /#{Regexp.quote(pattern)}/ if pattern.is_a?(String)
        [pattern, compile_rule(r)]
      }
    end
    
    def reset(text)
      @scanner = StringScanner.new(text)
      @token = fetch_next_token
      nil
    end
    
    def eos?
      @token.nil?
    end
    
    def next_token
      token = @token
      @token = fetch_next_token
      token
    end
    
    def each(&block)
      while !eos?
        yield next_token
      end
    end
    
    def scan(text)
      reset(text)
      inject([]) { |m, t| m << t }
    end
    
  private
  
    def fetch_next_token
      while !@scanner.eos?
        match = false
        @rules.each do |pattern, rule|
          if raw_token = @scanner.scan(pattern)
            match = true
            if rule.nil?
              break
            else
              return rule.call(raw_token)
            end
          end
        end
        raise "scan error; remaing text:\n\n#{@scanner.post_match}" unless match
      end
      nil
    end
    
    def compile_rule(rule)
      p1, p2 = rule.shift, rule.shift
      if p1.nil?
        nil
      elsif p1.respond_to?(:call)
        p1
      elsif p1.respond_to?(:to_sym)
        if p2
          if p2.respond_to?(:call)
            lambda { |t| [p1, p2.call(t)] }
          elsif p2.respond_to?(:to_sym)
            lambda { |t| [p1, t.send(p2.to_sym)] }
          else
            raise "second rule param must respond to :call or :to_sym"
          end
        else
          lambda { |t| [p1, t] }
        end
      else
        raise "first rule param must respond to :call or :to_sym"
      end
    end
    
  end
  
  class Parser
    def initialize(token_rules)
      @token_rules = token_rules
    end
    
    def parse(text)
      reset(text)
      accept
      ret = parse_program
      stop
      ret
    end
    
    def eval(text)
      parse(text)
    end
    
  private
  
    def parse_program
      raise "implement me"
    end
  
    def token_name
      @token ? @token[0] : nil
    end
    
    def token_value
      @token ? @token[1] : nil
    end
  
    def accept(token = nil)
      raise "parse error, expecting #{token.inspect}" if token && token != token_name
      @token = tokenizer.next_token
      nil
    end
    
    def stop
      raise "expecting EOF" unless @token.nil?
    end
  
    def reset(text)
      tokenizer.reset(text)
    end
    
    def tokenizer
      @tokenizer ||= build_tokenizer
    end
    
    def build_tokenizer
      Tokenizer.new(@token_rules)
    end
  end
end
