# typed: strict
# frozen_string_literal: true

require_relative "rox/version"
require 'sorbet-runtime'

module Rox
  class Prompt
    extend T::Sig
    sig {returns(NilClass)}
    def self.run
      loop do
        print "> "
        line = gets
        break if line.nil?
        Runner.run(line)
      end
    end
  end

  class FileRunner
    extend T::Sig
    sig {params(filename: String).void}
    def self.run(filename)
      program = File.read(filename)
      Runner.run(program)
    end
  end

  class Runner
    extend T::Sig
    sig {params(source: String).void}
    def self.run(source)
      scanner = Scanner.new(source)
      tokens = scanner.scan_tokens
      tokens.each {|t| puts t}
    rescue Error => e
      print_error(e)
    end

    sig {params(e: Error).void}
    def self.print_error(e)
      puts "[line #{e.line} Error #{e.where}: #{e.message}"
    end
  end

  class Scanner
    extend T::Sig

    sig {returns(String)}
    attr_reader :source

    sig {returns(Integer)}
    attr_reader :start

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
        start = current
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

    sig {returns(T::Boolean)}
    def is_at_end?
      current >= source.length
    end

    sig {returns(NilClass)}
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
      end
    end

    sig {returns(T.nilable(String))}
    def advance
      char = source[current]
      @current += 1
      char
    end

    sig {params(type: Token::Type, literal: T.nilable(Object)).returns(NilClass)}
    def add_token(type, literal: nil)
      text = source[start..current] || ''
      tokens << Token.new(type: type, lexeme: text, literal: literal, line: line)
      nil
    end
  end

  class Token 
    extend T::Sig
    class Type < T::Enum
      enums do
        # Single-character tokens.
        LEFT_PAREN = new
        RIGHT_PAREN = new 
        LEFT_BRACE = new
        RIGHT_BRACE = new

        COMMA = new

        DOT = new
        MINUS = new
        PLUS = new
        SEMICOLON = new
        SLASH = new
        STAR = new


        # One or two character tokens.
        BANG = new
        BANG_EQUAL = new

        EQUAL = new
        EQUAL_EQUAL = new

        GREATER = new
        GREATER_EQUAL = new

        LESS = new
        LESS_EQUAL = new

        # Literals.
        IDENTIFIER = new
        STRING = new
        NUMBER = new


        #   // Keywords.
        AND = new
        CLASS = new
        ELSE = new
        FALSE = new
        FUN = new
        FOR = new
        IF = new
        NIL = new
        OR = new

        PRINT = new
        RETURN = new
        SUPER = new
        THIS = new
        TRUE = new
        VAR = new
        WHILE = new


        EOF = new
      end
    end

    sig {returns(Type)}
    attr_reader :type

    sig {returns(String)}
    attr_reader :lexeme

    sig {returns(T.nilable(Object))}
    attr_reader :literal

    sig {returns(Integer)}
    attr_reader :line

    sig {params(type: Type, lexeme: String, literal: T.nilable(Object), line: Integer).void}
    def initialize(type: , lexeme:, literal:, line:)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @line = line
    end

    sig {returns(String)}
    def to_s
      "#{type} #{lexeme} #{literal}"
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
