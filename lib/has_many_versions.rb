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
  
  def <<(*records)
    upgrade_proxy_object do |new_version|
      proxy_reflection.klass.update_all(
        ['version = ?', new_version], 
        ["#{proxy_reflection.primary_key_name} = ? and version = ?", proxy_owner.id, new_version - 1]
      )
      flatten_deeper(records).each do |record|
        record.initial_version ||= proxy_owner.version
        record.version = proxy_owner.version
      end
      concat(*records)
    end
  end
  alias_method :push, :<<
  
  def delete_records(records)
    upgrade_proxy_object do |new_version|
      proxy_reflection.klass.update_all ['version = ?', new_version], ["#{proxy_reflection.primary_key_name} = ? and version = ? and #{proxy_reflection.klass.primary_key} not in (?)", proxy_owner.id, new_version - 1, records.collect(&proxy_reflection.klass.primary_key.to_sym)]
    end
  end
  
  def conditions
    interpolate_sql(@reflection.sanitized_conditions ?
      '%s AND %s.version = #{version}' % [@reflection.sanitized_conditions, proxy_reflection.quoted_table_name] :
      '%s.version = #{version}' % [proxy_reflection.quoted_table_name])
  end
  
  def rollback(target_version = nil)
    upgrade_proxy_object do |new_version|
      target_version ||= proxy_owner.version - 2
      proxy_reflection.klass.find(:all, :conditions => ['initial_version <= ? and version >= ?', target_version, target_version]).each do |new_record|
        new_record = new_record.clone
        new_record.initial_version = new_version
        new_record.version = new_version
        new_record.save!
      end
    end

  end
  
end
