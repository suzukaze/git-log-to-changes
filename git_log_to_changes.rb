require 'date'
require 'thor'

MRUBY_HOME=ENV['MRUBY_HOME']

class GitLogToChange < Thor
  default_command :show_commits

  @@github_authors = {
    'Akito Mochizuki' => 'ak-mochi-iij',
    'Akira Kuroda' => 'akuroda',
    'Anton Davydov' => 'davydovanton',
    'Ben A Morgan' => 'BenMorganIO',
    'Blaž Hrastnik' => 'archSeer',
    'Carson McDonald' => 'cremno',
    'Corey Powell' => 'IceDragon200',
    'Daniel Bovensiepen' => 'bovi',
    'David Turnbull' => 'AE9RB',
    'Eric Hodel' => 'drbrain',
    'Franck Verrot' => 'franckverrot',
    'Go Saito' => 'govm',
    'go.kikuta' => 'gkta',
    'iTitou' => 'iTitou',
    'INOUE Yasuyuki' => 'yasuyuki',
    'Hiroshi Mimaki' => 'mimaki',
    'Hiro Asari' => 'BanzaiMan',
    'Hiroyuki Matsuzaki' => 'Hiroyuki-Matsuzaki',
    'Huei-Horng Yo' => 'hiroshiyui',
    'Konstantin Haase' => 'rkh',
    'Jan Berdajs' => 'mrbrdo',
    'Jonas Kulla' => 'Ancurio',
    'Joachim Baran' => 'joejimbo',
    'Jose Narvaez' => 'goyox86',
    'Jared Breeden' => 'jbreeden',
    'Jun Hiroe' => 'suzukaze',
    'Julian Aron Prenner' => 'furunkel',
    'Jurriaan Pruis' => 'jurriaan',
    'Kazuho Oku' => 'kazuho',
    'Keita Obo' => 'ktaobo',
    'Kouhei Sutou' => 'kou ',
    'Yasuhiro Matsumoto' => 'mattn',
    'Lukas Joeressen' => 'kext',
    'murase_syuka' => 'murasesyuka',
    'Marcus Stollsteimer' => 'stomar',
    'Masaki Muranaka' => 'monaka',
    'MATSUMOTO Ryosuke' => 'matsumoto-r',
    'Miura Hideki' => 'miura1729',
    'Mitchell Blank Jr' => 'mitchblank',
    'Mitchell Hashimoto' => 'mitchellh',
    'M.Naruoka' => 'fenrir',
    'Nobuhiro Iwamatsu' => 'iwamatsu',
    'Nobuyoshi Nakada' => 'nobu',
    'Patrick Pokatilo' => 'SHyx0rmZ',
    'sasaki takeru' => 'takeru',
    'Seba Gamboa' => 'sagmor',
    'Simon Génier' => 'sgnr',
    'Robert Mosolgo' => 'rmosolgo',
    'Ralph Desir' => 'Mav7',
    'Santa Zhang' => 'santazhang',
    'takkaw' => 'takkaw',
    'Tatsuhiro Tsujikawa' => 'tatsuhiro-t',
    'Takeshi Watanabe' => 'take-cheeze',
    'Tarosa' => 'tarosay',
    'Tatsuhiko Kubo' => 'cubicdaiya',
    'Tatsuya Matsumoto' => 'Tatsuya Matsumoto',
    'Terence Lee' => 'hone',
    'Thiago Scalone' => 'scalone',
    'Tomoyuki Sahara' => 'tsahara-iij',
    'TOMITA Masahiro' => 'tmtm',
    'Utkarsh Kukreti' => 'utkarshkukreti',
    'Kazuki Tsujimoto' => 'k-tsj',
    'U.Nakamura' => 'unak',
    'Xuejie "Rafael" Xiao' => 'Xiao',
    'yui-knk' => 'yui-knk',
    'Syohei YOSHIDA' => 'syohex',
    'Yukihiro "Matz" Matsumoto' => 'matz',
    'Yuhei Okazaki' => 'Yuuhei-Okazaki',
    'Zachary Scott' => 'zzak',
  }

  desc "show_commits usage", "show_commits --days=[days]"
  method_option "days", desc: 'days'
  method_option "file", desc: 'file'
  def show_commits(name = 'default')
    @offset_day = 10
    if options['days']
      begin
      @offset_day = options['days'].to_i
      rescue
        puts "convert 1st argment Integer"
      end
    end
    
    commit_hashes = {}
    skip = false
    filename = options['file']
    if filename
      skip = true
      File.open(filename) do |file|
        file.each_line do |commit_hash|
          commit_hash.chomp!
          commit_hashes.store(commit_hash, true)
        end
      end
    end
    p commit_hashes
    puts "skip=#{skip}"
    if skip
      show(true, commit_hashes)
    else
      show
    end
  end

  no_commands do
    def show(skip = false, commit_hashes = nil)
      log = ""
      Dir.chdir(MRUBY_HOME) do
        date = (Date.today - @offset_day).strftime("%Y-%m-%d")
        puts date
        log = `git log --date=iso --pretty=format:"%adあ%hあ%anあ%sあ%H" --since=#{date}`
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
        elements = line.split("あ")
        day = elements[0][0, 16]
        commit_hash = elements[1]
        author = elements[2]
        subject = elements[3]
        commit = elements[4]
        if @@github_authors[author]
          github_author = @@github_authors[author]
        else
          github_author = author
        end

        if skip
          next unless commit_hashes[commit_hash]
        end
        puts <<"EOS"
####{day} #{github_author} [commit #{commit_hash}](https://github.com/mruby/mruby/commit/#{commit})
#{subject}

EOS
      end
    end
  end
end

GitLogToChange.start(ARGV)

