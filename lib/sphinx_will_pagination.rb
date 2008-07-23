module SphinxWillPagination
  def paginate_with_sphinx(query, options)
    per_page  = (options[:sphinx] && options[:sphinx][:limit]) ? options[:sphinx][:limit] : 20
    page      = (options[:sphinx] && options[:sphinx][:page] && options[:sphinx][:page].to_i > 0 ) ? options[:sphinx][:page].to_i : 1
    items = find_with_sphinx(query, options)
    items.instance_eval %{
      def total_entries
        total_found > 1000 ? 1000 : total_found
      end
      def total_pages
        (total_entries / #{per_page.to_f}).ceil
      end
      def current_page
        #{page}
      end
      def previous_page
        #{page > 1 ? page - 1 : nil}
      end
      def next_page
        #{page + 1}
        #{page} < total_pages ? #{page + 1} : nil
      end
      def page_count
        total_pages
      end
    }
    items
  end
end