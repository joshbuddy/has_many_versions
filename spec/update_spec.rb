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
  
  it "should record the 'from version' if that column exists" do
    Database.reset!(true)
    jasper = Author.new(:name => 'Jasper Fforde')
    eyre_affair = Book.new(:name => "The Eyre Affair")
    jasper.books << eyre_affair
    jasper.save!
    jasper.version.should == eyre_affair.version
    eyre_affair.initial_version.should == eyre_affair.version
    eyre_affair.name = 'The EYRE affair'
    jasper.books << eyre_affair
    jasper.books.first.from_version.should == eyre_affair.id
    jasper.books.first.id.should == 2
    jasper.books.first.name.should == 'The EYRE affair'
    jasper.books.rollback
    jasper.books.first.name.should == 'The Eyre Affair'
  end
  
  it "should record add, delete and update events all at the same time" do
    Database.reset!(true)
    jasper = Author.new(:name => 'Jasper Fforde')
    eyre_affair = Book.new(:name => "The Eyre Affair")
    shades_of_grey = Book.new(:name => "Shades of Grey")
    eyre_affair2 = Book.new(:name => "The Eyre Affair 2")
    shades_of_grey2 = Book.new(:name => "Shades of Grey 2")
    
    jasper.version.should == 1
    jasper.books = [eyre_affair, shades_of_grey]
    jasper.version.should == 2
    
    jasper.books = [shades_of_grey2, eyre_affair]
    jasper.version.should == 3
    
    jasper.books.rollback
    jasper.books.collect(&:name).should == ['The Eyre Affair', 'Shades of Grey']
    
  end
  
end
