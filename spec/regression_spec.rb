require 'spec_helper'

describe "regression" do
  describe "#escape_to_html" do
    it "should render the text as html" do
      path = File.expand_path(File.join(__FILE__, '../fixtures'))
      t = File.read(File.join(path, 'ansible_01.txt'))
      cvt = Ansible::Converter.new
      res = cvt.escape_to_html(t)
      res.should_not be_empty
    end
  end
end
