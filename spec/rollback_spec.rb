describe "HasManyVersions rollbacks" do

  before(:each) do
    Database.reset!
  end
  
  it "should rollback one step" do
    jasper = Author.new(:name => 'Jasper Fforde')
    eyre_affair = Book.new(:name => "The Eyre Affair")
    shades_of_grey = Book.new(:name => "Shades of Grey")
    jasper.save!
    jasper.books.push(eyre_affair, shades_of_grey)
    eyre_affair2 = Book.new(:name => "The Eyre Affair 2")
    shades_of_grey2 = Book.new(:name => "Shades of Grey 2")
    jasper.books.push(eyre_affair2, shades_of_grey2)
    eyre_affair3 = Book.new(:name => "The Eyre Affair 3")
    jasper.books.push(eyre_affair3)
    jasper.books.should == [eyre_affair, shades_of_grey, eyre_affair2, shades_of_grey2, eyre_affair3]
    jasper.books.rollback
    jasper.books.collect(&:name).should == [eyre_affair.name, shades_of_grey.name, eyre_affair2.name, shades_of_grey2.name]
  end

  it "should any number of steps" do
    jasper = Author.new(:name => 'Jasper Fforde')
    eyre_affair = Book.new(:name => "The Eyre Affair")
    shades_of_grey = Book.new(:name => "Shades of Grey")
    jasper.save!
    jasper.books.push(eyre_affair, shades_of_grey)
    eyre_affair2 = Book.new(:name => "The Eyre Affair 2")
    shades_of_grey2 = Book.new(:name => "Shades of Grey 2")
    jasper.books.push(eyre_affair2, shades_of_grey2)
    eyre_affair3 = Book.new(:name => "The Eyre Affair 3")
    jasper.books.push(eyre_affair3)
    jasper.books.should == [eyre_affair, shades_of_grey, eyre_affair2, shades_of_grey2, eyre_affair3]
    jasper.books.rollback(2)
    jasper.books.collect(&:name).should == [eyre_affair.name, shades_of_grey.name]
  end

  it "should rollback multiple times" do
    jasper = Author.new(:name => 'Jasper Fforde')
    eyre_affair = Book.new(:name => "The Eyre Affair")
    shades_of_grey = Book.new(:name => "Shades of Grey")
    jasper.save!
    jasper.books.push(eyre_affair, shades_of_grey)
    eyre_affair2 = Book.new(:name => "The Eyre Affair 2")
    shades_of_grey2 = Book.new(:name => "Shades of Grey 2")
    jasper.books.push(eyre_affair2, shades_of_grey2)
    eyre_affair3 = Book.new(:name => "The Eyre Affair 3")
    jasper.books.push(eyre_affair3)
    jasper.books.collect(&:name).should == [eyre_affair.name, shades_of_grey.name, eyre_affair2.name, shades_of_grey2.name, eyre_affair3.name]
    jasper.books.rollback(2)
    jasper.books.collect(&:name).should == [eyre_affair.name, shades_of_grey.name]
    jasper.books.rollback
    jasper.books.collect(&:name).should == [eyre_affair.name, shades_of_grey.name, eyre_affair2.name, shades_of_grey2.name, eyre_affair3.name]
    jasper.books.rollback(3)
    jasper.books.collect(&:name).should == [eyre_affair.name, shades_of_grey.name, eyre_affair2.name, shades_of_grey2.name]
  end

end
