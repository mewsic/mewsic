require 'resolv'

class SitemapController < ApplicationController
  layout nil

  if RAILS_ENV == 'production'
    before_filter :check_googlebot
  end

  def index
    @indexes = %w(users bands_and_deejays music ideas answers help_index multitrack)
    @resources = {
      'songs' => Song.find_published,
      'users' => User.find_activated,
      'answers' => Answer.find(:all),
      'help' => HelpPage.find(:all),
      'genres' => Genre.find_with_songs(:all),
      'mbands' => Mband.find_real
    }
  end

  private
    def check_googlebot
      address = Resolv::IPv4.create(request.remote_ip).to_name
      ptr = Resolv::DNS.open {|dns| dns.getname address }.to_s

      head :forbidden unless ptr =~ /\.googlebot\.com$/

    rescue Resolv::ResolvError
      head :bad_request
    end
end
