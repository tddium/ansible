# Ansible

## Overview

Ansible is an attempt at an ANSI-escape to HTML conversion tool that's fast
enough to use on large input.  Particularly, it's meant to be significantly
faster than the [ansi-sys](http://ansi-sys.rubyforge.org/) gem for large input
text.

## Installation

Install the gem:

     gem install ansible

## Usage

Here's an example of using Ansible in a rails controller:

     require 'ansible'

     class TextController << ApplicationController
       def show
         rawtext = Text.find(params[:id])
         @text = Ansible::ansi_escaped(rawtext)
       end
     end

Ansible will convert escapes into HTML `<span>` tags that apply sensible
classes that correspond to ANSI escape directives, like:

* ansible_green
* ansible_blue
* ansible_magenta

You can control the display of these with CSS however you please.

### Long input

For input beyond a certain size (default 65535 characters), Ansible will
automatically fall back to simply stripping escapes entirely.  You can control
this threshold when you call ansi_escaped:

     Ansible::ansi_escaped(rawtext, 32768)


## Where's the name Ansible come from?

An [ansible](http://en.wikipedia.org/wiki/Ansible) is a fictional faster than light
communication device.
