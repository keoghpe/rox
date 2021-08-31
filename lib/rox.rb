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
      raise Error.new if source.strip == "quit"
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

    sig {params(source: String).void}
    def initialize(source)
      @source = source
    end

    sig {returns(T::Array[Token])}
    def scan_tokens
      []
    end
  end

  class Token
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
