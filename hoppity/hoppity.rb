num = (File.open(String.new(ARGV[0].to_s)).read).strip.chomp.to_i
num.times { |n| n+=1;
  if (n % 5) == 0 && (n % 3) == 0
    puts 'Hop'
  elsif (n % 5) == 0
    puts 'Hophop'
  elsif (n % 3) == 0
    puts 'Hoppity'
  end
}