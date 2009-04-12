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

  #jasper.books << eyre_affair
  #  puts "version 1"
  #  p Author.all
  #  p Book.all
  #
  #  different_time = Book.new(:name => "different_time")
  #  jasper.books << different_time
  #
  #  puts "version 2"
  #  p Author.all
  #  p Book.all
  #
  #  puts "what about the associations?"
  #  p Author.first.books
  #
  #  puts "lets delete eyre affair"
  #  jasper.books.delete(eyre_affair)
  #
  #  p Author.first.books
  #  p Book.all
  #
  #  puts "rolling back!"
  #
  #  Author.first.books.rollback
  #
  #  puts "..and now?"
  #
  #  p Author.first.books
  #  p Book.all
  #
  #  puts "rolling back to 1..."
  #
  #  Author.first.books.rollback(2)
  #
  #  puts "..and now?"
  #
  #  p Author.first.books
  #  p Book.all
  #  
