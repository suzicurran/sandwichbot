last_id = File.read("last_id.txt")
puts last_id
new_id = "James"
File.write("last_id.txt", new_id)