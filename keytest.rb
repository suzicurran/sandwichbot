last_key = File.read("last_key.txt")
puts last_key
new_key = "James"
File.write("last_key.txt", new_key)