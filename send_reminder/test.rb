#!/usr/bin/env ruby

def my_func(name="nanashi_san")
  puts "hello, " + name.to_s
end
 
air = [0.5, 1.5, 3, 5.5, 6] 
for i in air do
  my_func(i)
end

