#!env ruby

require 'net/ssh'
require 'net/ssh/shell'
require 'yajl'
require 'net/scp'
#The backupinator

#Procedure:
#SSH into servers
#Run the commands given.
#Move all backup to external servers

#space <-> labitat.dk
#space <-> food
#space <-> door
#space <-> anna
#move from space to offsite (davsebamse.dk)


#Read config file
json = File.new('backupinator.conf', 'r')
parser = Yajl::Parser.new

config = parser.parse(json)

backupdirname = "backup"+Time.now.to_i

config["servers"].each do |server|
    Net::SSH.start(server["host"], server["user"], :password => server["password"], :port => server["port"]) do |ssh|
		ssh.exec "mkdir "+backupdirname
		ssh.shell do |sh|
      		server["commands"].each do |cmd|
				res = sh.execute! cmd
				res.on_output do |data|
					puts data
				end
			end
		end
		ssh.scp.download! backupdirname, "."
    end
end

