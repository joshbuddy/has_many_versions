require File.join(File.dirname(__FILE__), 'spec_helper')

describe "HasManyVersions updating" do

  before(:each) do
    Database.reset!
  end
  
  it "interpret changed? objects as new and allow rolling back to that state" do
    jasper = Author.new(:name => 'Jasper Fforde')
    eyre_affair = Book.new(:name => "The Eyre Affair")
    jasper.books << eyre_affair
    jasper.save!
    jasper.version.should == eyre_affair.version
    eyre_affair.initial_version.should == eyre_affair.version
    eyre_affair.name = 'The EYRE affair'
    jasper.books << eyre_affair
    jasper.books.first.name.should == 'The EYRE affair'
    jasper.books.rollback
    jasper.books.first.name.should == 'The Eyre Affair'
  end
  
end
