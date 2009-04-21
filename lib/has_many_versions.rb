module ActiveRecord
  module Associations
    class AssociationCollection
      alias_method :__concat__, :<<
    end
  end
end

module HasManyVersions
  
  def upgrade_proxy_object
    proxy_owner.transaction do
      new_version = proxy_owner.version + 1
      proxy_owner.version = new_version
      proxy_owner.class.update_all ['version = ?', new_version], ["#{proxy_reflection.klass.primary_key} = ?", proxy_owner.id]
      proxy_owner.save!
      yield new_version
      proxy_owner.reload
    end
  end
  
  def replace(other_array)
    other_array.each { |val| raise_on_type_mismatch(val) }

    load_target
    other   = other_array.size < 100 ? other_array : other_array.to_set
    current = @target.size < 100 ? @target : @target.to_set

    upgrade_proxy_object do |new_version|
      delete_records_without_versioning_transaction(new_version, @target.select { |v| !other.include?(v) })
      add_records_without_versioning_transaction(new_version, other_array.select { |v| !current.include?(v) }, @target.select { |v| !other.include?(v) }.collect(&:id))
    end
  end
  
  def add_records_without_versioning_transaction(new_version, records, excluded_ids = [])
    changing_records = flatten_deeper(records).select{|r| !r.new_record? && r.changed?}
    excluded_ids.concat(changing_records.collect(&:id)) unless changing_records.empty?
    excluded_ids.empty? ? 
      proxy_reflection.klass.update_all(
        ['version = ?', new_version], 
        ["#{proxy_reflection.primary_key_name} = ? and version = ?", proxy_owner.id, new_version - 1]
      ) : proxy_reflection.klass.update_all(
        ['version = ?', new_version], 
        ["#{proxy_reflection.primary_key_name} = ? and version = ? and #{proxy_reflection.klass.primary_key} not in (?)", proxy_owner.id, new_version - 1, excluded_ids]
      )
    records = flatten_deeper(records).collect do |r|
      if !r.new_record? && r.changed?
        new_r = r.clone
        new_r.from_version = r.id if new_r.respond_to?(:from_version=)
        new_r
      else
        r
      end
    end
    flatten_deeper(records).each do |record|
      record.initial_version = proxy_owner.version if record.new_record?
      record.version = proxy_owner.version
    end
    __concat__(*records)
  end
  
  
  def <<(*records)
    upgrade_proxy_object do |new_version|
      add_records_without_versioning_transaction(new_version, records)
    end
  end
  
  alias_method :push, :<<
  alias_method :concat, :<<
  
  def delete_records_without_versioning_transaction(new_version, records)
    proxy_reflection.klass.update_all ['version = ?', new_version], ["#{proxy_reflection.primary_key_name} = ? and version = ? and #{proxy_reflection.klass.primary_key} not in (?)", proxy_owner.id, new_version - 1, records.collect(&proxy_reflection.klass.primary_key.to_sym)]
  end

  def delete_records(records)
    upgrade_proxy_object do |new_version|
      delete_records_without_versioning_transaction(new_version, records)
    end
  end
  
  def conditions
    interpolate_sql(@reflection.sanitized_conditions ?
      '%s AND %s.version = #{version}' % [@reflection.sanitized_conditions, proxy_reflection.quoted_table_name] :
      '%s.version = #{version}' % [proxy_reflection.quoted_table_name])
  end
  
  def rollback(target_version = proxy_owner.version - 1)
    upgrade_proxy_object do |new_version|
      proxy_reflection.klass.find(:all, :conditions => ['initial_version <= ? and version >= ?', target_version, target_version]).each do |new_record|
        new_record = new_record.clone
        new_record.initial_version = new_version
        new_record.version = new_version
        new_record.save!
      end
    end

  end
  
end
