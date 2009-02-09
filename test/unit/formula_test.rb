require File.dirname(__FILE__) + '/../test_helper'

class FormulaTest < ActiveSupport::TestCase
    fixtures :formulas
    
    def test_evaluate
        formula = formulas(:Rectangular_Prism)
        res = formula.evaluate(:length => 2, :width => 3, :height => 4)
        assert_equal(24, res)
        assert_not_equal(34, res)

        # test using floating points in options
        formula = formulas(:Rectangular_Prism)
        res = formula.evaluate(:length => 2.1, :width => 3.2, :height => 4.3)
        assert_in_delta(28.896, res, 0.00001)
        assert_not_equal(28, res)

        # test using floating points in constants
        formula = formulas(:box_fp)
        res = formula.evaluate(:length => 2, :width => 3, :height => 4)
        assert_in_delta(2.4, res, 0.0001)
        assert_not_equal(24, res)

        # test using not all parameters
        formula = formulas(:area)
        res = formula.evaluate(:length => 2, :height => 3)
        assert_equal(6, res)
        assert_not_equal(34, res)
      
        # test that required parameters not passed in will fail
        formula = formulas(:box)
        assert_raise(RuntimeError) {formula.evaluate()}

        # test exponentiation
        formula = formulas(:Cylinder)
        res = formula.evaluate(:width => 4, :height => 6)
        assert_in_delta(75.408, res, 0.00001)
        assert_not_equal(34, res)

        # more exponetiation
        formula = formulas(:Sphere)
        res = formula.evaluate(:width => 4, :height => 6)
        assert_in_delta(33.512, res, 0.00001)
        assert_not_equal(34, res)

        # a digit must be preceeded by a digit
        formula = formulas(:box_bad_dot)
        assert_raise(RuntimeError) do
            formula.evaluate(:length => 2, :width => 4, :height => 6)
        end
    end

    def test_validate_format()
        formula = Formula.new(:name => 'foo')

        # Note that you don't test for presence of whitespace character
        # because there is a validates_presence_of validation on the 
        # model.
        good_characters = ['0', '9', 'H', 'W', 'L', '*', '+', '-', '(', ')', '.']
        good_characters.each() do |char|
            formula.formula = char
            assert_equal(true, formula.valid?(), "Invalid unit test character: #{char}")
        end

        # A sampling of some disallowed characters
        bad_characters = ['h', 'w', 'l', 'E', 'e', '&', '%', '=' '/']
        bad_characters.each() do |char|
            formula.formula = char
            assert_equal(false, formula.valid?(), "Invalid unit test character: #{char}")
        end

        # Ensure that a full formula is valid.
        formula.formula = 'H * W * L'
        assert_equal(true, formula.valid?())
    end
end
