module Ansible
  def escape_to_html(data)
    data = span("none", 0, true) + data

    { 30 => :black,
      31 => :red,
      32 => :green,
      33 => :yellow,
      34 => :blue,
      35 => :magenta,
      36 => :cyan,
      37 => :white,
      90 => :gray
    }.each do |key, value|
      data.gsub!(/\e\[(\d;)?#{key}m/) { |match|
        span(value, $1)
      }
    end

    data.gsub!(/\e\[0?m/, span("none"))
    data.gsub!(/\e\[(\d;)?(\d+)m/) { |match|
      span($2, $1)
    }
    data + "</span>"
  end

  def strip_escapes(string)
    string.gsub!(/\e\[(\d;)?\d*m/, "")
    string
  end

  def ansi_escaped(string, maxlen=65535)
    return '' unless string
    if string.size < maxlen
      z = escape_to_html(string)
    else
      z = strip_escapes(string.to_s)
    end
    z
  end

  private
    def span(klass, level=0, first=false)
      s = first ? "" : "</span>"

      classes = ["ansible_#{klass}"]
      classes << "ansible_bold" if level.to_i == 1
      s += %Q{<span class="#{classes.join(" ")}">}
      s
    end
end
