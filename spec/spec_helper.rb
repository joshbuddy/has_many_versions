require 'rubygems'
require 'spec'
require 'activerecord'
require 'rails/init'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

Spec::Runner.configure do |config|
  
end

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.establish_connection(YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml')))

class Database
  def self.reset!(with_from_version = false)
    ActiveRecord::Schema.define :version => 0 do
      create_table :books, :force => true do |t|
        t.integer :author_id
        t.integer :initial_version
        t.integer :from_version if with_from_version
        t.integer :version
        t.string :name
      end

      create_table :authors, :force => true do |t|
        t.integer :version, :default => 1
        t.string :name
      end
      
      Book.reset_column_information
    end
  end

end

class Book < ActiveRecord::Base
  belongs_to :author
  validates_associated :author
end

class Author < ActiveRecord::Base
  has_many :books, :extend => HasManyVersions
end
