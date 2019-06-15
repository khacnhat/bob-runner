require_relative 'bash_stub_tar_pipe_out'
require_relative 'test_base'

class RoundTripTest < TestBase

  def self.hex_prefix
    'ECF'
  end

  # - - - - - - - - - - - - - - - - -

  test '526', %w( created text files (including dot files) are returned ) do
    script = [
      'echo -n "xxx" > newfile.txt',
      'echo -n "yyy" > .dotfile'
    ].join(';')

    all_OSes.each do |os|
      set_OS(os)
      assert_cyber_dojo_sh(script)
      assert_created({
        'newfile.txt' => intact('xxx'),
        '.dotfile' => intact('yyy')
      })
      assert_deleted([])
      assert_changed({})
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '527', %w( created binary files are not returned ) do
    script = [
      'dd if=/dev/zero of=binary.dat bs=1c count=42',
      'file --mime-encoding binary.dat'
    ].join(';')

    all_OSes.each do |os|
      set_OS(os)
      assert_cyber_dojo_sh(script)
      assert stdout.include?('binary.dat: binary')
      assert_created({})
      assert_deleted([])
      assert_changed({})
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '529', %w( text files created in sub-dirs are returned ) do
    dirname = 'sub'
    path = "#{dirname}/newfile.txt"
    content = 'jjj'
    script = [
      "mkdir #{dirname}",
      "echo -n '#{content}' > #{path}"
    ].join(';')

    all_OSes.each do |os|
      set_OS(os)
      assert_cyber_dojo_sh(script)
      assert_created({ path => intact(content) })
      assert_deleted([])
      assert_changed({})
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '530', %w( deleted files are detected ) do
    all_OSes.each do |os|
      set_OS(os)
      filename = src_file(os)
      script = "rm #{filename}"
      assert_cyber_dojo_sh(script)
      assert_created({})
      assert_deleted([filename])
      assert_changed({})
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '531', %w( changed files are detected ) do
    all_OSes.each do |os|
      set_OS(os)
      filename = src_file(os)
      content = 'XXX'
      script = "echo -n '#{content}' > #{filename}"
      assert_cyber_dojo_sh(script)
      assert_created({})
      assert_deleted([])
      assert_changed({filename => intact(content)})
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '532', %w( empty new text files are detected ) do
    # The file utility says empty files are binary files!
    filename = 'empty.txt'
    script = "touch #{filename}"
    all_OSes.each do |os|
      set_OS(os)
      assert_cyber_dojo_sh(script)
      assert_created({filename => intact('')})
      assert_deleted([])
      assert_changed({})
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '533', %w( single-char new text files are detected ) do
    # The file utility says single-char files are binary files!
    filename = 'one-char.txt'
    ch = 'x'
    script = "echo -n '#{ch}' > #{filename}"
    all_OSes.each do |os|
      set_OS(os)
      assert_cyber_dojo_sh(script)
      assert_created({filename => intact(ch)})
      assert_deleted([])
      assert_changed({})
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '62C',
  %w( no text files under /sandbox at all, returns everything unchanged ) do
    all_OSes.each do |os|
      set_OS(os)
      assert_cyber_dojo_sh('rm -rf /sandbox/* /sandbox/.*')
      assert_created({})
      assert_deleted([])
      assert_changed({})
    end
  end

  private # = = = = = = = = = = = = =

  def src_file(os)
    case os
    when :Alpine then 'Hiker.cs'
    when :Ubuntu then 'hiker.pl'
    when :Debian then 'hiker.py'
    end
  end

end
