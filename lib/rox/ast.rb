# typed: true
require 'sorbet-runtime'

module Rox
  module AST
    refine String do
      def underscore
        self.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end
    end

    using self

    class Token < T::Struct
    end

    module Expr 
      extend T::Sig
      extend T::Helpers    

      interface!

      sig {abstract.params(visitor: Visitor)}
      def apply(visitor)
      end
    end

    def self.define_ast(types)
      types.each do |type|
        class_name, attributes = type.split(":").map(&:strip)
        new_class = Class.new(T::Struct) do 
          include Expr

          attributes.split(",").each do |attribute|
            type, name = attribute.split(" ").map(&:strip)

            prop name.to_sym, Rox::AST.const_get(type)

            define_method(:apply) do |visitor|
              visitor.send("#visit_#{self.class.to_s.underscore}", self)
            end
          end
        end

        const_set(class_name, new_class)
      end

      new_module = Module.new do
        extend T::Sig
        extend T::Helpers    

        interface!

        types.each do |type|
          class_name, _attributes = type.split(":").map(&:strip)

          sig {abstract}
          define_method("visit_#{class_name.underscore}") {}
        end
      end

      const_set("Visitor", new_module)
    end

    define_ast([
      "Binary     : Expr left, Token operator, Expr right",
      "Grouping   : Expr expression",
      "Literal    : Object value",
      "Unary      : Token operator, Expr right",
    ])

    class AstPrinter
      extend T::Sig

      include Visitor

      def print(expr)
      end

      def visit_unary(expr)
      end

      def visit_binary(expr)
      end

      def visit_grouping(expr)
      end

      def visit_literal(expr)
      end
    end
  end
end