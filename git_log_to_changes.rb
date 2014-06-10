require 'date'

MRUBY_HOME='/Users/hiroejun/work/mruby/mruby'

github_authors = {
  'Akira Kuroda' => 'akuroda',
  'Carson McDonald' => 'cremno',
  'Daniel Bovensiepen' => 'bovi',
  'iTitou' => 'iTitou',
  'Konstantin Haase' => '',
  'Joachim Baran' => 'joejimbo',
  'Jun Hiroe' => 'suzukaze',
  'Keita Obo' => 'ktaobo',
  'Kouhei Sutou' => 'kou ',
  'mattn' => 'mattn',
  'Marcus Stollsteimer' => 'stomar',
  'Masaki Muranaka' => 'monaka',
  'Miura Hideki' => 'miura1729',
  'Mitchell Blank Jr' => 'mitchblank',
  'Mitchell Hashimoto' => 'mitchellh',
  'Nobuyoshi Nakada' => 'nobu',
  'sasaki takeru' => 'takeru',
  'Takeshi Watanabe' => 'take-cheeze',
  'takkaw' => 'takkaw',
  'Tatsuhiko Kubo' => 'cubicdaiya',
  'Tatsuya Matsumoto' => 'Tatsuya Matsumoto',
  'Tomoyuki Sahara' => 'tsahara-iij',
  'Utkarsh Kukreti' => 'utkarshkukreti',
  'Kazuki Tsujimoto' => 'k-tsj',
  'U.Nakamura' => 'unak',
  'Yukihiro "Matz" Matsumoto' => 'matz',
  'yui-knk' => 'yui-knk'
}

offset_day = 1
if ARGV.length > 0
  begin
    offset_day = ARGV[0].to_i
  rescue
    puts "convert 1st argment Integer"
  end
end

log = ""
Dir.chdir(MRUBY_HOME) do
  date = (Date.today - offset_day).strftime("%Y-%m-%d")
  puts date
  log = `git log --date=iso --pretty=format:"%ad,%h,%an,%s,%H" --since=#{date}`
end

logs = log.split("\n")
logs = logs.delete_if { |e| /Merge pull request/.match(e) != nil  }
logs = logs.delete_if { |e| /Merge branch/.match(e) != nil  }
logs.map do |log|
  log.gsub!(/#\d+/) {|number| "[#{number}](https://github.com/mruby/mruby/pull/#{number[1..-1]})" }
end
logs = logs.reverse

puts logs

logs.each do |line|
  elements = line.split(",")
  day = elements[0][0, 16]
  shorten_commit = elements[1]
  author = elements[2]
  subject = elements[3]
  commit = elements[4]
  if github_authors[author]
    github_author = github_authors[author]
  else
    github_author = author
  end

  puts <<"EOS"
####{day} #{github_author} [commit #{shorten_commit}](https://github.com/mruby/mruby/commit/#{commit})
#{subject}

EOS
end

