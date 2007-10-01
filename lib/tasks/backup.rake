
desc "Backup Everything Specified in config/backup.yml"
task :backup => [ "backup:db",  "backup:push"]

namespace :backup do
 
    RAILS_APPDIR = RAILS_ROOT.sub("/config/..","")
    
   def interesting_tables
     ActiveRecord::Base.connection.tables.sort.reject! do |tbl|
       ['schema_info', 'sessions', 'public_exceptions'].include?(tbl)
     end
   end
  
   def sync_remote(sftp, local_path, remote_path)

       # note, this only syncs one level deep

       file_perm = 0644
       dir_perm = 0755
       
       new_files = 0
       updated_files = 0
       corrected_files = 0       
 
       # make sure remote path exists
        begin
         sftp.stat(remote_path)
        rescue Net::SFTP::Operations::StatusException => e 
         raise unless e.code == 2
         sftp.mkdir(remote_path, :mode => dir_perm)
        end
       
       # cache remote file info
       handle = sftp.opendir(remote_path)
       remote_files = sftp.readdir(handle)
       sftp.close_handle(handle)
       remote_filenames = remote_files.collect { |f| f.filename }

       # loop thru all files in local dir
       Find.find(local_path) do |local_file|
         # skip dirs ( . and .. )
         next if File.stat(local_file).directory?
         # potential remote file with full path
         new_remote_file = remote_path + local_file.sub(local_path, '')
         # just the filename
         new_remote_filename = new_remote_file.split("/").last
         
         do_copy = false
             # check to see if file exists on remote host
             if existing_remote_file = remote_files.find { |f| f.filename == new_remote_filename }
                # check and see if local file modified sooner than existing remote one 
                if File.stat(local_file).mtime > Time.at(existing_remote_file.attributes.mtime)
                  puts "Copying updated #{local_file} to #{new_remote_file}"
                  updated_files += 1
                  do_copy = true
                else  # check and see if local file size is the same as the remote size
                  if File.stat(local_file).size != existing_remote_file.attributes.size
                   puts "existing remote file size was not the same as local recopying"
                   puts "Copying #{local_file} to #{new_remote_file}"
                   corrected_files += 1
                   do_copy = true
                  end
                end
             else
               # file dont exist copy it over
               puts "Copying new #{local_file} to #{new_remote_file}"
               new_files += 1
               do_copy = true
             end  

         if do_copy
          sftp.put_file(local_file, new_remote_file)
          sftp.setstat(new_remote_file, :mode => file_perm)
         end
       end
 
       puts "#{new_files} new files copied"
       puts "#{updated_files} files updated"
       puts "#{corrected_files} files corrected"
       puts "#{local_path} synced to #{remote_path}\n\n"
   end
   
   desc "Push backup to remote server"
   task :push  => [:environment] do 
      FileUtils.chdir(RAILS_APPDIR)
      backup_config = YAML::load( File.open( 'config/backup.yml' ) )[RAILS_ENV]
      for server in backup_config["servers"]
       puts "Backing up #{RAILS_ENV} directorys #{backup_config['dirs'].join(', ')} to #{server['name']}"
       puts "Time is " + Time.now.rfc2822 + "\n\n"
       Net::SSH.start(server['host'], server['port'], server['user']) do |ssh|
        ssh.sftp.connect do |sftp|
         for dir in backup_config["dirs"]
          local_dir = RAILS_APPDIR + "/" + dir + "/"
          remote_dir = server['dir'] + "/" + dir.split("/").last + "/"
          puts "Syncing #{local_dir} to #{server['host']}#{remote_dir}"
          sync_remote(sftp, local_dir, remote_dir)
         end
        end
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
