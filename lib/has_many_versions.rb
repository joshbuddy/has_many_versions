module HasManyVersions

  def insert_record(record)
    proxy_owner.transaction do
      # upgrade object
      new_version = proxy_owner.version + 1
      proxy_owner.version = new_version
      proxy_owner.class.update_all ['version = ?', new_version], ["#{proxy_reflection.klass.primary_key} = ?", proxy_owner.id]
      proxy_reflection.klass.update_all ['version = ?', new_version], ["#{proxy_reflection.primary_key_name} = ? and version = ?", proxy_owner.id, new_version - 1]
    end
    super
  end

  def delete_records(records)
    new_version = proxy_owner.version + 1
    proxy_owner.version = new_version
    proxy_owner.save!
    proxy_reflection.klass.update_all ['version = ?', new_version], ["#{proxy_reflection.primary_key_name} = ? and version = ? and #{proxy_reflection.klass.primary_key} not in (?)", proxy_owner.id, new_version - 1, records.collect(&proxy_reflection.klass.primary_key.to_sym)]
  end
  
  def conditions
    parent_conditions = super
    version_condition = interpolate_sql('%s.version = #{version}' % proxy_reflection.quoted_table_name)
    parent_conditions ? parent_conditions + ' and ' + version_condition : version_condition
  end
  
  def rollback(target_version = nil)
    proxy_owner.transaction do
      new_version = proxy_owner.version + 1
      target_version ||= proxy_owner.version - 1
      proxy_owner.version = new_version
      proxy_owner.class.update_all ['version = ?', new_version], ["#{proxy_reflection.klass.primary_key} = ?", proxy_owner.id]
      
      proxy_reflection.klass.find(:all, :conditions => ['initial_version <= ? and version >= ?', target_version, target_version]).each do |new_record|
        new_record = new_record.clone
        new_record.initial_version = new_version
        new_record.version = new_version
        new_record.save!
      end
    end
  end
  
end
