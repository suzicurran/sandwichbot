require 'csv'

ingredients_array = CSV.read("ingredients_import.csv")
primary = ingredients_array[0].sample
secondary = ingredients_array[1].sample
condiment = ingredients_array[2].sample
bread = ingredients_array[3][0..20].sample

puts "Have #{primary} and #{secondary} with #{condiment} on #{bread}."