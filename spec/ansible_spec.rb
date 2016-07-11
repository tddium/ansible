require 'spec_helper'

describe Ansible do
  ANSIBLE_NONE = %Q{<span class="ansible_none">}
  ANSIBLE_RED = %Q{<span class="ansible_31">}
  ANSIBLE_GREEN = %Q{<span class="ansible_1 ansible_32">}
  subject { Ansible::Converter.new } 

  describe "#escape_to_html" do
    it "should strip ansi escapes" do
      SAMPLE_TEXT = {
        "escaped [31mtext[0m" => "escaped text",
        "escaped [0;31mtext[0m" => "escaped text",
        "escaped [0;31mtext[0m" => "escaped text",
        "escaped [0;31mtext [1;32mother[0m" => "escaped text other",
        "escaped [0;31mtext [1;32mother[0m[m" => "escaped text other",
        "escaped [1;95mtext[0m" => "escaped text",
        "escaped [42;37;1mtext[0m" => "escaped text"
      }

      SAMPLE_TEXT.each do |t, v|
        subject.escape_to_html(t).should == v
      end
    end
  end
#  describe "#ansi_escaped" do
#    SAMPLE_TEXT = {
#      "escaped [31mtext[0m" =>
#           %Q{#{ANSIBLE_NONE}escaped </span>#{ANSIBLE_RED}text</span>#{ANSIBLE_NONE}</span>},
#      "escaped [0;31mtext[0m" =>
#           %Q{#{ANSIBLE_NONE}escaped </span>#{ANSIBLE_RED}text</span>#{ANSIBLE_NONE}</span>},
#      "escaped [0;31mtext[0m" =>
#           %Q{#{ANSIBLE_NONE}escaped </span>#{ANSIBLE_RED}text</span>#{ANSIBLE_NONE}</span>},
#      "escaped [0;31mtext [1;32mother[0m" =>
#           %Q{#{ANSIBLE_NONE}escaped </span>#{ANSIBLE_RED}text </span>#{ANSIBLE_GREEN}other</span>#{ANSIBLE_NONE}</span>},
#      "escaped [0;31mtext [1;32mother[0m[m" =>
#           %Q{#{ANSIBLE_NONE}escaped </span>#{ANSIBLE_RED}text </span>#{ANSIBLE_GREEN}other</span>#{ANSIBLE_NONE}</span>#{ANSIBLE_NONE}</span>},
#      "escaped [1;95mtext[0m" =>
#           %Q{#{ANSIBLE_NONE}escaped </span><span class="ansible_1 ansible_95">text</span>#{ANSIBLE_NONE}</span>},
#      "escaped [42;37;1mtext[0m" =>
#           %Q{#{ANSIBLE_NONE}escaped </span><span class="ansible_42 ansible_37 ansible_1">text</span>#{ANSIBLE_NONE}</span>},
#    }
#
#    it "should render the text as html" do
#      SAMPLE_TEXT.each do |t, v|
#        subject.ansi_escaped(t).should_not =~ /\e/
#      end
#    end
#
#    it "should inject span tags" do
#      SAMPLE_TEXT.each do |t,v|
#        subject.ansi_escaped(t).should == v
#      end
#    end
#
#    it "should handle long input" do
#      long_input = "[32mabcd[m" * 41000
#      subject.ansi_escaped(long_input).should_not =~ /\e/
#    end
#
#    context "(nil)" do
#      it "should echo an empty string" do
#        subject.ansi_escaped(nil).should == ''
#      end
#    end
#  end
end
