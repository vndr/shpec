describe "shpec"
  describe "basic operations"
    it "asserts equality"
      assert equal "foo" "foo"
    end

    it "asserts inequality"
      assert unequal "foo" "bar"
    end

    it "asserts less than"
      assert lt 5 7
    end

    it "asserts greater than"
      assert gt 7 5
    end

    it "asserts partial matches"
      assert match "partially" "partial"
    end

    it "asserts lack of partial matches"
      assert no_match "zebra" "giraffe"
    end

    it "asserts presence"
      assert present "something"
    end

    it "asserts blankness"
      assert blank ""
    end
  end

  describe "equality matcher"
    it "handles newlines properly"
      string_with_newline_char="new\nline"
      multiline_string='new
line'
      assert equal "$multiline_string" "$string_with_newline_char"
    end

    it "compares strings containing single quotes"
      assert equal "a' b" "a' b"
    end

    it "compares strings containing double quotes"
      assert equal 'a" b' 'a" b'
    end
  end

  describe "lt matcher"
    it "handles numbers of different length properly"
      assert lt 5 17
    end
  end

  describe "gt matcher"
    it "handles numbers of different length properly"
      assert gt 17 5
    end
  end

  describe "passing through to the test builtin"
    it "asserts an arbitrary algebraic test"
      assert test "[[ 5 -lt 10 ]]"
    end
  end

  describe "stubbing commands"
    it "stubs to the null command by default"
      stub_command "exit"
      exit # doesn't really exit
      assert equal "$?" 0
      unstub_command "exit"
    end

    it "accepts an optional function body"
      stub_command "curl" "echo 'stubbed body'"
      assert equal "$(curl)" "stubbed body"
      unstub_command "curl"
    end
  end

  describe "testing files"
    it "asserts file absence"
      assert file_absent /tmp/foo
    end

    it "asserts file existence"
      touch /tmp/foo
      assert file_present /tmp/foo
      rm /tmp/foo
    end

    it "can verify the pointer of a symlink"
      ln -s $HOME /tmp/link
      assert symlink /tmp/link "$HOME"
      rm /tmp/link
    end
  end

  describe "custom matcher"
    it "allows custom matchers"
      assert custom_assertion "argument"
    end
  end

  describe "exit codes"
    shpec_cmd="$SHPEC_ROOT/../bin/shpec"
    it "returns nonzero if any test fails"
      $shpec_cmd $SHPEC_ROOT/etc/failing_example &> /dev/null
      assert unequal "$?" "0"
    end

    it "returns zero if a suite passes"
      $shpec_cmd $SHPEC_ROOT/etc/passing_example &> /dev/null
      assert equal "$?" "0"
    end
  end

  describe "output"
    it "outputs passing tests to STDOUT"
      message="$(. $SHPEC_ROOT/etc/passing_example)"
      assert match "$message" "a\ passing\ test"
    end

    it "outputs failing tests to STDOUT"
      message="$(. $SHPEC_ROOT/etc/failing_example)"
      assert match "$message" "a\ failing\ test"
    end
  end

  describe "commandline options"
    shpec_cmd="$SHPEC_ROOT/../bin/shpec"

    describe "--version"
      it "outputs the current version number"
        message="$($shpec_cmd --version)"
        assert match "$message" "$(cat $SHPEC_ROOT/../VERSION)"
      end
    end

    describe "-v"
      it "outputs the current version number"
        message="$($shpec_cmd -v)"
        assert match "$message" "$(cat $SHPEC_ROOT/../VERSION)"
      end
    end
  end

  describe "compatibility"
    it "works with old-style syntax"
      message="$(. $SHPEC_ROOT/etc/old_example)"
      assert match "$message" "old\ example"
    end
  end
end
