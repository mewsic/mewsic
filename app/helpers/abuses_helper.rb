module AbusesHelper
  def report_abuse_link_to(url)
    link_to('report abuse', url, :class => 'lightview', :rel => 'ajax', :title => 'Report abuse :: :: ajax:{method:"get"},width:480,height:350') if logged_in?
  end
end
