require File.join(File.dirname(__FILE__), 'spec_helper')

describe "HasManyVersions deleting" do

  before(:each) do
    Database.reset!
  end
  
  it "should delete from the associations and increment the version" do
    jasper = Author.new(:name => 'Jasper Fforde')
    eyre_affair = Book.new(:name => "The Eyre Affair")
    shades_of_grey = Book.new(:name => "Shades of Grey")
    jasper.save!
    jasper.books.push(eyre_affair, shades_of_grey)
    initial_version = jasper.version
    jasper.books.delete(eyre_affair)
    jasper.books.should == [shades_of_grey]
    jasper.books.first.version.should == 3
  end
end
