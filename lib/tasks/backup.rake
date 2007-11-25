desc "Backup Everything Specified in config/backup.yml"
task :backup => [ "backup:db",  "backup:push"]

namespace :backup do
 
    RAILS_APPDIR = RAILS_ROOT.sub("/config/..","")
    
   def interesting_tables
     ActiveRecord::Base.connection.tables.sort.reject! do |tbl|
       ['schema_info', 'sessions', 'public_exceptions'].include?(tbl)
     end
   end
  
   desc "Push backup to remote server"
   task :push  => [:environment] do 
      FileUtils.chdir(RAILS_APPDIR)
      backup_config = YAML::load( File.open( 'config/backup.yml' ) )[RAILS_ENV]
      for server in backup_config["servers"]
       puts "Backing up #{RAILS_ENV} directorys #{backup_config['dirs'].join(', ')} to #{server['name']}"
       puts "Time is " + Time.now.rfc2822 + "\n\n"
         for dir in backup_config["dirs"]
          local_dir = RAILS_APPDIR + "/" + dir + "/"
          remote_dir = server['dir'] + "/" + dir.split("/").last + "/"
          puts "Syncing #{local_dir} to #{server['host']}#{remote_dir}"
          sh "/usr/bin/rsync -avz -e 'ssh -p#{server['port']} ' #{local_dir} #{server['user']}@#{server['host']}:#{remote_dir}"
         end
       puts "Completed backup to #{server['name']}\n\n"
      end
   end

    task :storedb => :environment do 

      backupdir = RAILS_APPDIR + '/db/backup'
      FileUtils.mkdir_p(backupdir)
      FileUtils.chdir(backupdir)
      puts "Dumping database to activerecord yaml files in #{backupdir}"
      interesting_tables.each do |tbl|

        klass = tbl.classify.constantize
        puts "Writing #{tbl}..."
        File.open("#{tbl}.yml", 'w+') { |f| YAML.dump klass.find(:all).collect(&:attributes), f }      
      end
      puts "Database Dumped.\n\n"
    end

    desc "Dump Current Environment Db to file"    
    task :db => [:environment, :storedb ] do
      backupdir = RAILS_APPDIR + '/db/backup'
      archivedir = RAILS_APPDIR + '/db/backups'
      backup_filename = "#{RAILS_ENV}_db_backup_#{Time.now.strftime("%B.%d.%Y_at_%I.%M.%S%p_%Z")}.tar.bz2"
      FileUtils.mkdir_p(archivedir)
      puts "Archiving #{backupdir} yaml files to #{backup_filename}\n\n"
      `tar -C #{backupdir} -cjf #{backup_filename} *`
      `mv #{backup_filename} #{archivedir}`
    end

    desc "Restore Current Environment Db from a file"    
    task :restoredb => [:environment] do 
        backupdir = RAILS_APPDIR + '/db/backup'
        archivedir = RAILS_APPDIR + '/db/backups'
        print "Input a file to load into the db: #{archivedir}/"
        backup_filename = STDIN.gets.chomp
        puts "Loading backup file: #{backup_filename}"
        FileUtils.chdir(archivedir)
        `tar -xjf #{backup_filename}`
        `mv *.yml #{backupdir}`
        FileUtils.mkdir_p(backupdir)
        FileUtils.chdir(backupdir)
    
        interesting_tables.each do |tbl|
        puts "Clearing #{tbl} table.."
        ActiveRecord::Base.connection.execute "TRUNCATE #{tbl}"
        puts "Loading #{tbl} backup file..."
        table = YAML.load_file("#{tbl}.yml")        

        if table.length > 0 && table.first.key?("id")
            highestid = 0
            table.each do |fixture|
             if fixture["id"] > highestid
                highestid = fixture["id"]
             end
            end

            ActiveRecord::Base.connection.execute "SELECT setval('#{tbl}_id_seq',#{highestid})"
            puts "Setting #{tbl}_id sequence to #{highestid}"
        end
         
        #klass = tbl.classify.constantize
        ActiveRecord::Base.transaction do 
        
          puts "Inserting #{table.length} values into #{tbl}"
          table.each do |fixture|
            ActiveRecord::Base.connection.execute "INSERT INTO #{tbl} (#{fixture.keys.join(",")}) VALUES (#{fixture.values.collect { |value| ActiveRecord::Base.connection.quote(value) }.join(",")})", 'Fixture Insert'
          end        
          puts "#{tbl} table restored.\n\n"
        end
       end
    end

 
end
