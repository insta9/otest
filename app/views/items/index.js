jQuery('tbody#item_body').html('<%= escape_javascript render("items") %>');
jQuery('.paginator').html('<%= escape_javascript(paginate(@items, :remote => true).to_s) %>' +
    '<div class="paging_info"><%= page_entries_info @items %></div>');