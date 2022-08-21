# typed: true

module Rox
  class Scanner
    extend T::Sig

    sig {returns(String)}
    attr_reader :source

    sig {returns(Integer)}
    attr_accessor :start

    sig {returns(Integer)}
    attr_accessor :current

    sig {returns(Integer)}
    attr_accessor :line

    sig {returns(T::Array[Token])}
    attr_accessor :tokens

    sig {params(source: String).void}
    def initialize(source)
      @source = source
      @start = T.let(0, Integer)
      @current = T.let(0, Integer)
      @line = T.let(0, Integer)
      @tokens = T.let([], T::Array[Token])
    end

    sig {returns(T::Array[Token])}
    def scan_tokens

      while !is_at_end? do
        self.start = current
        scan_token
      end

      tokens << Token.new(
        type: Token::Type::EOF,
        lexeme: '',
        literal: nil,
        line: line,
      )

      tokens
    end

    sig {void}
    def scan_token
      c = advance

      case c
      when '('
        add_token(Token::Type::LEFT_PAREN)
      when ')'
        add_token(Token::Type::RIGHT_PAREN)
      when '{'
        add_token(Token::Type::LEFT_BRACE)
      when '}'
        add_token(Token::Type::RIGHT_BRACE)
      when ','
        add_token(Token::Type::COMMA)
      when '.'
        add_token(Token::Type::DOT)
      when '-'
        add_token(Token::Type::MINUS)
      when '+'
        add_token(Token::Type::PLUS)
      when ';'
        add_token(Token::Type::SEMICOLON)
      when '*'
        add_token(Token::Type::STAR)
      when "\n"
        # TODO: ADD OTHER LINE ENDINGS
        add_token(Token::Type::RETURN)
      else
        raise Error.new('Unexpected character.', line, c || '')
      end
    end

    sig {returns(T::Boolean)}
    def is_at_end?
      current >= source.length
    end

    sig {returns(T.nilable(String))}
    def advance
      char = source[current]
      @current += 1
      char
    end

    sig {params(type: Token::Type, literal: T.nilable(Object)).void}
    def add_token(type, literal: nil)
      text = source[start..(current - 1)] || ''
      # puts "start #{start} current #{current} #{type}"
      tokens << Token.new(type: type, lexeme: text, literal: literal, line: line)
    end
  end


  class Error < StandardError
    extend T::Sig

    sig {returns(Integer)}
    attr_reader :line

    sig {returns(String)}
    attr_reader :where

    sig {params(message: String, line: Integer, where: String).void}
    def initialize(message='', line=-1, where='')
      @line = line
      @where = where
      super(message)
    end
  end
end