require File.dirname(__FILE__) + '/../test_helper'

class InstrumentTest < ActiveSupport::TestCase
  fixtures :instruments, :instrument_categories

  def test_should_validate_and_set_icon
    instr = Instrument.new(:description => 'drums')
    deny instr.save
    assert instr.errors.on(:description)
    assert instr.errors.on(:category_id)

    instr = Instrument.new(:description => 'clavicembalo',
                           :category => instrument_categories(:chordophones))
    assert instr.save
    assert_not_nil instr.reload.icon
  end

  def test_find_by_name
    assert_equal instruments(:conga), Instrument.by_name.find(:first)
  end

end
