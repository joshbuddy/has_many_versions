require File.join(File.dirname(__FILE__), 'spec_helper')

describe "HasManyVersions adding" do

  before(:each) do
    Database.reset!
  end
  
  it "should start with a version of 1" do
    jasper = Author.new(:name => 'Jasper Fforde')
    jasper.save!
    jasper.version.should == 1
  end

  it "should increment the version and the associated object should match it" do
    jasper = Author.new(:name => 'Jasper Fforde')
    eyre_affair = Book.new(:name => "The Eyre Affair")
    jasper.books << eyre_affair
    jasper.save!
    jasper.version.should == eyre_affair.version
    eyre_affair.initial_version.should == eyre_affair.version
  end
  
  it "should be able to get two books and return them" do
    jasper = Author.new(:name => 'Jasper Fforde')
    eyre_affair = Book.new(:name => "The Eyre Affair")
    shades_of_grey = Book.new(:name => "Shades of Grey")
    jasper.save!
    old_version = jasper.version
    jasper.books << eyre_affair
    jasper.books << shades_of_grey
    jasper.books.should == [eyre_affair, shades_of_grey]
    jasper.books.each {|b| b.version.should == (old_version + 2) }
  end

end
