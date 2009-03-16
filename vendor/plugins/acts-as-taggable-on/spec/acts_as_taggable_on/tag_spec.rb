require File.dirname(__FILE__) + '/../spec_helper'

describe Tag do
  before(:each) do
    @tag = Tag.new
    @user = TaggableModel.create(:name => "Pablo")  
  end
  
  it "should require a name" do
    @tag.name = nil
    @tag.should_not be_valid
    @tag.name = "something"
    @tag.should be_valid
  end
  
  it "should equal a tag with the same name" do
    @tag.name = "awesome"
    new_tag = Tag.new(:name => "awesome")
    new_tag.should == @tag
  end
  
  it "should return its name when to_s is called" do
    @tag.name = "cool"
    @tag.to_s.should == "cool"
  end
end