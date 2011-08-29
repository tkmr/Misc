require 'ruby-growl'

module God
  module Contacts
    class GodGrowl < Contact
      def notify( message, time, priority, category, host )
        # priority ||= 0
        # @growl ||= Growl.new('localhost', 'God', ['test'])
        # @growl.notify('test', 'God crashy test', message, priority, false)
        system "growlnotify -t 'god' -m '#{message}' -p -1"
      end
    end
  end
end
