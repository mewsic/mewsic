# Copyright:: (C) 2008 Medlar s.r.l.
# Copyright:: (C) 2008 Mikamai s.r.l.
#
# == Schema Information
#
# Table name: users
#
#  id                        :integer(11)   not null, primary key
#  login                     :string(255)   
#  email                     :string(255)   
#  remember_token            :string(255)   
#  activation_code           :string(255)   
#  country                   :string(45)    
#  city                      :string(40)    
#  first_name                :string(32)    
#  last_name                 :string(32)    
#  gender                    :string(20)    
#  photos_url                :string(255)   
#  blog_url                  :string(255)   
#  myspace_url               :string(255)   
#  skype                     :string(255)   
#  msn                       :string(255)   
#  msn_public                :boolean(1)    
#  skype_public              :boolean(1)    
#  crypted_password          :string(40)    
#  salt                      :string(40)    
#  string                    :string(40)    
#  type                      :string(255)   
#  motto                     :text          
#  tastes                    :text          
#  remember_token_expires_at :datetime      
#  activated_at              :datetime      
#  friends_count             :integer(11)   
#  age                       :integer(11)   
#  password_reset_code       :string(255)   
#  created_at                :datetime      
#  updated_at                :datetime      
#  rating_count              :integer(11)   
#  rating_total              :decimal(10, 2 
#  rating_avg                :decimal(10, 2 
#  replies_count             :integer(11)   default(0)
#  nickname                  :string(20)    
#  is_admin                  :boolean(1)    
#  status                    :string(3)     default("off")
#  name_public               :boolean(1)    
#  multitrack_token          :string(64)    
#  podcast_public            :boolean(1)    default(TRUE)
#  profile_views             :integer(11)   default(0)
#
# == Description
#
# Subclass of User that uses Rails' Single-Table-Inheritance to implement different
# kinds of users. See also +Dj+ and +User+.
#
class Band < User

  #has_many :members, :class_name => 'BandMember', :foreign_key => :band_id
  
end
