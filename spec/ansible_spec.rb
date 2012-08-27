require 'spec_helper'
require 'benchmark'

describe Ansible do
  ANSIBLE_NONE = %Q{<span class='ansible_none'>}
  ANSIBLE_RED = %Q{<span class='ansible_31'>}
  ANSIBLE_GREEN = %Q{<span class='ansible_1 ansible_32'>}
  subject { Ansible::Converter.new } 

  describe "#escape_to_html" do
    SAMPLE_TEXT = {
      "escaped [31mtext[0m" =>
           %Q{#{ANSIBLE_NONE}escaped </span>#{ANSIBLE_RED}text</span>#{ANSIBLE_NONE}</span>},
      "escaped [0;31mtext[0m" =>
           %Q{#{ANSIBLE_NONE}escaped </span>#{ANSIBLE_RED}text</span>#{ANSIBLE_NONE}</span>},
      "escaped [0;31mtext[0m" =>
           %Q{#{ANSIBLE_NONE}escaped </span>#{ANSIBLE_RED}text</span>#{ANSIBLE_NONE}</span>},
      "escaped [0;31mtext [1;32mother[0m" =>
           %Q{#{ANSIBLE_NONE}escaped </span>#{ANSIBLE_RED}text </span>#{ANSIBLE_GREEN}other</span>#{ANSIBLE_NONE}</span>},
      "escaped [0;31mtext [1;32mother[0m[m" =>
           %Q{#{ANSIBLE_NONE}escaped </span>#{ANSIBLE_RED}text </span>#{ANSIBLE_GREEN}other</span>#{ANSIBLE_NONE}</span>#{ANSIBLE_NONE}</span>},
      "escaped [1;95mtext[0m" =>
           %Q{#{ANSIBLE_NONE}escaped </span><span class='ansible_1 ansible_95'>text</span>#{ANSIBLE_NONE}</span>},
      "escaped [42;37;1mtext[0m" =>
           %Q{#{ANSIBLE_NONE}escaped </span><span class='ansible_42 ansible_37 ansible_1'>text</span>#{ANSIBLE_NONE}</span>},
    }

    it "should render the text as html" do
      SAMPLE_TEXT.each do |t, v|
        res = subject.escape_to_html(t)
        res.should_not =~ /\e/
      end
    end

    it "should inject span tags" do
      SAMPLE_TEXT.each do |t,v|
        subject.escape_to_html(t).should == v
      end
    end

    it "should handle long input" do
      long_input = "[32mabcd[m" * 100000
      res = nil
      time = Benchmark.realtime do
        res = subject.escape_to_html(long_input)
      end
      puts "Escape #{long_input.size} took #{time * 1000}ms"
      res.should_not =~ /\e/
    end

    context "(nil)" do
      it "should echo an empty string" do
        subject.escape_to_html(nil).should == ''
      end
    end
  end
end
