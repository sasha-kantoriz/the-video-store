# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/home/dp/Documents/dp/the-video-store"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/home/dp/Documents/dp/the-video-store/pids/unicorn.pid"

# Path to logs
# stderr_path "/path/to/logs/unicorn.log"
# stdout_path "/path/to/logs/unicorn.log"
stderr_path "/home/dp/Documents/dp/logs/unicorn.log"
stdout_path "/home/dp/Documents/dp/logs/unicorn.log"

# Unicorn socket
# listen "/tmp/unicorn.[app name].sock"
listen "/tmp/unicorn.myapp.sock"

# Number of processes
# worker_processes 4
worker_processes 2

# Time-out
timeout 30