simple_parser.rb
================

A tiny toolkit for writing recursive-descent parsers in Ruby. This is not a parser-generator; it's for those circumstances where hand-rolling is quicker
than bringing out the heavy machinery.

Two components:

 * a generic tokenzier that is seeded with a list of regular expressions and
   simple transformations to perform whenever a match is encountered. This was
   shamelessly inspired by Python's `re.Scanner`, gleaned of during a
   recent sniff around the [Lamson](http://lamsonproject.org/) sources.
 * a skeleton recursive descent parser implementing a few utility methods like
   `accept` and `stop`.

Using the tokenizer
-------------------

Writing tokenizers is the grubbiest part of hacking together a parser so this is
where `SimpleParser` helps you the most.

Initialize a tokenizer thusly:

    tokenizer = SimpleParser::Tokenizer.new([
      # token rules
    ])
    
Where each rule obeys the format:

    [ string_or_regexp, (optional) param_1, (optional) param_2 ]
    
`string_or_regexp` defines the token to be matched, and any regex must be unanchored.
The tokenizer will try each rule in order until a match is found, so it's possible
to control precedence through careful arrangement of your rules.

The optional parameters to each rule define how a raw match is transformed to an
output value. Supported combinations are:

     Param 1     | Param 2     | Result
    -------------+-------------+-----------------------------------------
     not present | not present | (token is ignored)
     symbol      | not present | [symbol, token_string]
     block       | not present | block.call(token_string)
     symbol_1    | symbol_2    | [symbol_1, token_string.send(symbol_2)]
     symbol      | block       | [symbol, block.call(token_string)]
    
Once the tokenizer has been instantiated, a bunch of methods are available:

    # scan text and return array of tokens
    tokenizer.scan(text)
    
    # re-initialize tokenizer with text
    tokenizer.reset(text)
    
    # returns true if no more tokens remain
    tokenizer.eos?
    
    # read the next token
    tokenizer.next_token
    
    # iterate (does not reset before iterating)
    tokenizer.each do |t|
      # do some funky shit
    end
    
Examples
--------

There's a small example, utilising both the tokenizer and parser components, in
`calculator.rb`.
