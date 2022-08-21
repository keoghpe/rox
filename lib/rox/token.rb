# typed: true

module Rox
  class Token 
    extend T::Sig
    class Type < T::Enum
      enums do
        # Single-character tokens.
        LEFT_PAREN = new("LEFT_PAREN")
        RIGHT_PAREN = new("RIGHT_PAREN") 
        LEFT_BRACE = new("LEFT_BRACE")
        RIGHT_BRACE = new("RIGHT_BRACE")

        COMMA = new("COMMA")

        DOT = new("DOT")
        MINUS = new("MINUS")
        PLUS = new("PLUS")
        SEMICOLON = new("SEMICOLON")
        SLASH = new("SLASH")
        STAR = new("STAR")


        # One or two character tokens.
        BANG = new("BANG")
        BANG_EQUAL = new("BANG_EQUAL")

        EQUAL = new("EQUAL")
        EQUAL_EQUAL = new("EQUAL_EQUAL")

        GREATER = new("GREATER")
        GREATER_EQUAL = new("GREATER_EQUAL")

        LESS = new("LESS")
        LESS_EQUAL = new("LESS_EQUAL")

        # Literals.
        IDENTIFIER = new("IDENTIFIER")
        STRING = new("STRING")
        NUMBER = new("NUMBER")


        #   // Keywords.
        AND = new("AND")
        CLASS = new("CLASS")
        ELSE = new("ELSE")
        FALSE = new("FALSE")
        FUN = new("FUN")
        FOR = new("FOR")
        IF = new("IF")
        NIL = new("NIL")
        OR = new("OR")

        PRINT = new("PRINT")
        RETURN = new("RETURN")
        SUPER = new("SUPER")
        THIS = new("THIS")
        TRUE = new("TRUE")
        VAR = new("VAR")
        WHILE = new("WHILE")


        EOF = new("EOF")
      end

    end

    KEYWORDS = {
        "and": Type::AND,
        "class": Type::CLASS,
        "else": Type::ELSE,
        "false": Type::FALSE,
        "fun": Type::FUN,
        "for": Type::FOR,
        "if": Type::IF,
        "nil": Type::NIL,
        "or": Type::OR,
        "print": Type::PRINT,
        "return": Type::RETURN,
        "super": Type::SUPER,
        "this": Type::THIS,
        "true": Type::TRUE,
        "var": Type::VAR,
        "while": Type::WHILE,
    }



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
      "#{type.serialize} #{lexeme} #{literal}"
    end
  end
end