require 'rubygems'
require 'spec'
require 'activerecord'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'has_many_versions'

Spec::Runner.configure do |config|
  
end

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.establish_connection(YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml')))

class Database
  def self.reset!
    ActiveRecord::Schema.define :version => 0 do
      create_table :books, :force => true do |t|
        t.integer :author_id
        t.integer :initial_version
        t.integer :version
        t.string :name
      end

      create_table :authors, :force => true do |t|
        t.integer :version, :default => 1
        t.string :name
      end
    end
  end

end

class Book < ActiveRecord::Base
  belongs_to :author
  
  validates_associated :author
  
  before_create do |r|
    r.version = r.initial_version = r.author.version
  end
  
end

class Author < ActiveRecord::Base
  has_many :books, :extend => HasManyVersions
end
