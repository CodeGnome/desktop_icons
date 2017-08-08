#!/usr/bin/env ruby

# macos_desktop_icons.rb: Manage state of desktop icons on macOS.
#
# Copyright © 2017 Todd A. Jacobs
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

class DesktopIcons
  HIDE = false
  SHOW = true

  class EX_OSERR_71 < NotImplementedError
    def initialize msg="not macOS"
      super
    end
  end

  def initialize
    raise EX_OSERR_71 unless macOS?
  end

  def hide
    desktop_icons HIDE
  end

  def show
    desktop_icons SHOW
  end

  def toggle
    toggle_icon_display
    restart_finder
  end

  private

  def macOS?
    `uname -s`&.start_with? 'Darwin'
  end

  def icons_showing?
    `defaults read com.apple.finder CreateDesktop`.chomp == 'true'
  end

  def inverted_setting
    !icons_showing?
  end

  def toggle_icon_display
    bool = inverted_setting
    cmd  = %w[defaults write com.apple.finder CreateDesktop] << bool
    system cmd.join " "
    restart_finder
    icons_showing?
  end

  def restart_finder
    system 'pkill Finder'
  end

  def desktop_icons bool
    return if icons_showing? == bool
    cmd  = %w[defaults write com.apple.finder CreateDesktop] << bool
    system cmd.join " "
    restart_finder
  end
end

if __FILE__ == $0
  if ENV['DEBUG']
    d = DesktopIcons.new
    d.icons_showing?
    d.inverted_setting
    d.toggle_icon_display
  else
    DesktopIcons.new.send ARGV[0] || 'toggle'
  end
end
