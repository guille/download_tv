require "test_helper"

describe DownloadTV::Configuration do
  config_path = File.realdirpath("#{__dir__}/test_config")

  before do
    Dir.chdir(__dir__)
  end

  after do
    File.delete(config_path) if File.exist?(config_path)
  end

  describe "when the file already exists" do
    it "will load the existing configuration (blank)" do
      create_dummy_config(config_path)

      c = DownloadTV::Configuration.new(path: config_path)
      c.content.must_equal ({path: config_path, version: DownloadTV::VERSION})
    end

    it "will load the existing configuration (existing)" do
      create_dummy_config(config_path, auto: false, myepisodes_user: "dummy")

      c = DownloadTV::Configuration.new(path: config_path)
      c.content.must_equal ({path: config_path, auto: false, myepisodes_user: "dummy", version: DownloadTV::VERSION})
    end

    it "will get overwritten by the parameters given" do
      create_dummy_config(config_path, myepisodes_user: "dummy")

      c = DownloadTV::Configuration.new(path: config_path, myepisodes_user: "fake")
      c.content.must_equal ({path: config_path, myepisodes_user: "fake", version: DownloadTV::VERSION})
    end

    it "will downcase ignored shows" do
      create_dummy_config(config_path, ignored: ["duMMy", "String"])

      c = DownloadTV::Configuration.new(path: config_path)
      c.content[:ignored].must_equal ["dummy", "string"]
    end
  end

  describe "the breaking_changes method" do
    it "returns nil when both versions are equal" do
      create_dummy_config(config_path)

      c = DownloadTV::Configuration.new(path: config_path)
      c.breaking_changes?(DownloadTV::VERSION).must_be_nil
    end

    it "returns true when there's been a major update" do
      create_dummy_config(config_path)

      split = DownloadTV::VERSION.split(".")
      split[0] = (split[0].to_i+1).to_s
      new_version = split.join(".")
      c = DownloadTV::Configuration.new(path: config_path)
      c.breaking_changes?(new_version).must_equal true
    end

    it "returns true when there's been a minor update" do
      create_dummy_config(config_path)

      split = DownloadTV::VERSION.split(".")
      split[1] = (split[1].to_i+1).to_s
      new_version = split.join(".")
      c = DownloadTV::Configuration.new(path: config_path)
      c.breaking_changes?(new_version).must_equal true
    end

    it "returns false when it's a small patch" do
      create_dummy_config(config_path)

      split = DownloadTV::VERSION.split(".")
      split[2] = (split[2].to_i+1).to_s
      new_version = split.join(".")
      c = DownloadTV::Configuration.new(path: config_path)
      c.breaking_changes?(new_version).must_equal false
    end
  end

  describe "when the file doesn't exist" do
    it "will create a new one" do
      run_silently do
        STDIN.stub :gets, "myepisodes\ncookie\nignored" do
          DownloadTV::Configuration.new(path: config_path)
        end
      end

      File.exist?(config_path).must_equal true
    end

    it "will have the right values" do
      c = nil
      run_silently do
        STDIN.stub :gets, "anything" do
          c = DownloadTV::Configuration.new(path: config_path)
        end
      end

      c.content[:myepisodes_user].must_equal "anything"
      c.content[:cookie].must_equal true
      c.content[:ignored].must_equal ["anything"]
      c.content[:auto].must_equal true
      c.content[:subs].must_equal true
      c.content[:grabber].must_equal "TorrentAPI"
      c.content[:date].must_equal Date.today-1
      c.content[:version].must_equal DownloadTV::VERSION

    end

    it "will set the cookie value to false when explicitly told so" do
      c = nil
      run_silently do
        STDIN.stub :gets, "n" do
          c = DownloadTV::Configuration.new(path: config_path)
        end
      end

      c.content[:cookie].must_equal false
    end

    it "will separate the ignored values by commas" do
      c = nil
      run_silently do
        STDIN.stub :gets, "ignored1, itsgone, ignored 2" do
          c = DownloadTV::Configuration.new(path: config_path)
        end
      end
      c.content[:ignored].must_equal ["ignored1", "itsgone", "ignored 2"]
    end
  end

  describe "the serialize method" do
    it "stores the configuration in a Marshal'd file" do
      # Calls serialize
      run_silently do
        STDIN.stub :gets, "anything" do
          DownloadTV::Configuration.new(path: config_path)
        end
      end
      content = File.open(config_path, "rb") { |f| Marshal.load(f) }

      content[:cookie].must_equal true
      content[:myepisodes_user].must_equal "anything"
      content[:ignored].must_equal ["anything"]
      content[:auto].must_equal true
      content[:subs].must_equal true
      content[:grabber].must_equal "TorrentAPI"
      content[:date].must_equal Date.today-1
      content[:version].must_equal DownloadTV::VERSION
    end
  end

  describe "the constructor" do
    it "will trigger a configuration change when asked to" do
      create_dummy_config(config_path, auto: false)
      File.exist?(config_path).must_equal true
      c = nil

      run_silently do
        STDIN.stub :gets, "anything" do
          c = DownloadTV::Configuration.new(path: config_path)
        end
      end

      c.content[:auto].must_equal false
    end
  end

end