# typed: true
require 'sorbet-runtime'

module Rox
  module AST
    class Token < T::Struct
    end

    module Expr 
      extend T::Sig
      extend T::Helpers    

      interface!
    end

    def self.define_ast(types)
      types.each do |type|
        class_name, attributes = type.split(":").map(&:strip)
        new_class = Class.new(T::Struct) do 
          include Expr

          attributes.split(",").each do |attribute|
            type, name = attribute.split(" ").map(&:strip)

            prop name.to_sym, Rox::AST.const_get(type)
          end
        end

        const_set(class_name, new_class)
      end
    end

    define_ast([
      "Binary   : Expr left, Token operator, Expr right",
      "Grouping   : Expr expression",
      "Literal   : Object value",
      "Unary   : Token operator, Expr right",
    ])
  end
end