# == Schema Information
#
#  email :string        
#  body  :text          
#
# == Description
#
# This table-less model represents an help request sent via e-mail on the <tt>/help</tt> page
# of the site. Created by HelpController#ask and delivered by MyousicaMailer#help_request.
# It's implemented as a tableless model in order to take advantage of ActiveRecord validations.
#
# == Validations
#
# * <b>validates_presence_of</b> <tt>email</tt> and <tt>body</tt>
# * <b>validates_format_of</b> <tt>email</tt> with an extensive Regexp.
#
class HelpRequest < ActiveRecord::Base
  has_no_table

  column :email, :string
  column :body, :text

  validates_presence_of :email, :body
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
end
