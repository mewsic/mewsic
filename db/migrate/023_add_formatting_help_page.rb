class AddFormattingHelpPage < ActiveRecord::Migration
  def self.up
    h = HelpPage.new
    h.title = 'Formatting help'
    h.body = '<table> <tr> <th style="width: 120px;">To get this&hellip;</th> <th style="width: 280px;">Type this&hellip;</th> </tr> <tr> <td> <strong>Bold phrase</strong> </td> <td><code> &lt;strong&gt;Bold phrase&lt;/strong&gt; or<br/> &lt;b&gt;Bold phrase&lt;/b&gt; </code></td> </tr> <tr> <td> <span style="font-style: italic;">Italic phrase</span> </td> <td><code> &lt;i&gt;Italic phrase&lt;/i&gt; or<br/> &lt;em&gt;Italic phrase&lt;/em&gt; </code></td> </tr> <tr> <td> <ul> <li>Bulleted list</li> <li>Bulleted list</li> </ul> </td> <td><code> &lt;ul&gt;<br /> &lt;li&gt;Bulleted list&lt;/li&gt;<br /> &lt;li&gt;Bulleted list&lt;/li&gt;<br /> &lt;/ul&gt; </code></td> </tr> <tr> <td> <small>Small text</small> </td> <td><code> &lt;small&gt;Indented block&lt;/small&gt; </code></td> </tr> <td><a href="http://www.myousica.com">Myousica</a></td> <td><code>&lt;a href="http://www.myousica.com"&gt; Myousica &lt;/a&gt;</code></td> </tr> </table>'
    h.save!
  end

  def self.down
    HelpPage.find_by_title('Formatting help').destroy rescue nil
  end
end
