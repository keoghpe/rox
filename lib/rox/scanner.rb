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
      when '!'
        add_token(match?("=") ? Token::Type::BANG_EQUAL : Token::Type::BANG)
      when '='
        add_token(match?("=") ? Token::Type::EQUAL_EQUAL : Token::Type::EQUAL)
      when '<'
        add_token(match?("=") ? Token::Type::LESS_EQUAL : Token::Type::LESS)
      when '>'
        add_token(match?("=") ? Token::Type::GREATER_EQUAL : Token::Type::GREATER)
      when '/'
        if match?('/')
          advance while peek != "/n" && !is_at_end?
        else
          add_token(Token::Type::SLASH)
        end
      when " ", "\r", "\t"
      when "\n"
        self.line += 1
      else
        raise Error.new('Unexpected character.', line, c || '')
      end
    end

    # Implements a "lookahead" it looks at the next char without consuming it
    # Too keep the language fast, this should be kept to 1 or two characters
    sig {returns(T.nilable(String))}
    def peek
      return "\0" if is_at_end?
      source[current]
    end

    sig {params(char: String).returns(T::Boolean)}
    def match?(char)
      is_match = !is_at_end? && source[current] == char
      advance if is_match
      is_match
    end

    sig {returns(T::Boolean)}
    def is_at_end?
      current >= source.length
    end

    sig {returns(T.nilable(String))}
    def advance
      @current += 1
      source[current - 1]
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