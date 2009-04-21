require File.join(File.dirname(__FILE__), 'spec_helper')

describe "HasManyVersions history" do

  before(:each) do
    Database.reset!
  end
  
  it "should give you a history" do
    Database.reset!(true)
    jasper = Author.new(:name => 'Jasper Fforde')
    
    books = (1..100).collect do |i|
      book = Book.new(:name => "Book #{i}", :id => i)
      book.save!
      book
    end
    jasper.save!
    titles = [[]]
    jasper.books = [Book.find(1), Book.find(10), Book.find(11), Book.find(23), Book.find(99)]
    titles << jasper.books.collect(&:name)
    jasper.books = [Book.find(1), Book.find(10), Book.find(12), Book.find(25), Book.find(94)]
    titles << jasper.books.collect(&:name)
    jasper.books = [Book.find(1), Book.find(10), Book.find(12), Book.find(25), Book.find(94), Book.find(87)]
    titles << jasper.books.collect(&:name)
    jasper.books = [Book.find(2), Book.find(4), Book.find(5)]
    titles << jasper.books.collect(&:name)
    jasper.books = [Book.find(1), Book.find(10), Book.find(11), Book.find(23), Book.find(99)]
    titles << jasper.books.collect(&:name)
    
    jasper.books.history.each do |history|
      history.state.collect(&:name).should == titles.shift
    end
    
  end
  
end
