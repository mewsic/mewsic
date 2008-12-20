class SitemapController < ApplicationController
  layout nil

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
end
