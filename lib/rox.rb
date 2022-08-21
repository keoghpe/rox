# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative "rox/version"
require_relative "rox/token"
require_relative "rox/scanner"

module Rox
  class Prompt
    extend T::Sig
    sig {void}
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
      puts "[line #{e.line}] Error #{e.where}: #{e.message}"
    end
  end

end
